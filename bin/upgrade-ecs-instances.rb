#!/usr/bin/env ruby
require 'aws-sdk'
require 'active_support/core_ext/hash'
require 'pp'

include Aws

ec2 = EC2::Client.new

## Setup
# Find AMI
puts "Please provide the latest AMI id for eu-central (can be found on https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html):"
ami_id = gets.chomp
ami = ec2.describe_images({ filters: [{name: 'owner-alias', values: ['amazon']}, {name: 'image-id', values: [ami_id] }]}).images.first

fail 'Image not found' if ami.nil?

# Update launch configuration
as = AutoScaling::Client.new
last_lc = as.describe_launch_configurations.launch_configurations.
  select { |lc| lc.launch_configuration_name =~ /^ecs-instance-v\d+$/ }.
  sort_by(&:launch_configuration_name).
  last
last_lc_name = last_lc.launch_configuration_name
new_lc_name = last_lc_name.gsub(/v(\d+)/) { |_| "v#{($1.to_i + 1)}" }

new_lc = last_lc.to_hash.slice(:key_name,
                               :security_groups,
                               :classic_link_vpc_security_groups,
                               :user_data,
                               :instance_type,
                               :instance_monitoring,
                               :iam_instance_profile,
                               :ebs_optimized,
                               :associate_public_ip_address)
new_lc.merge!({
  launch_configuration_name: new_lc_name,
  image_id: ami.image_id,
  block_device_mappings: last_lc.block_device_mappings.map do |bdm|
    bdm.to_hash.slice(:device_name, :virtual_name, :no_device).merge({
      ebs: bdm.ebs.to_hash.slice(:volume_size, :volume_type)
    })
  end
})

as.create_launch_configuration(new_lc)

puts 'Created new Launch Configuration with new AMI'

# Update ASG
asg = as.describe_auto_scaling_groups.auto_scaling_groups.detect { |asg| asg.launch_configuration_name == last_lc_name }
as.update_auto_scaling_group({
  auto_scaling_group_name: asg.auto_scaling_group_name,
  launch_configuration_name: new_lc_name,
  desired_capacity: asg.desired_capacity + 1
})

puts 'Updated Auto Scaling Group with new Launch Configuration & added 1 instance'

# Find redis master

## Update loop
# slaves.each:
#   drain, wait, terminate instance
#   reset redis sentinel
#   check ES health, wait until green
# fail over redis master
# drain master

## Clean up
# verify:
#    All N nodes are up and all services have no pending containers
#    The old master instance is empty
#    All sentinels agree on the cluster state, i.e. number of slaves and sentinels
#    The sentinel ELB has N healthy instances
#    The elasticsearch cluster status is green

# detach master from ASG, reducing count by one
