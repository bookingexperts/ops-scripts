#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'

def main
  sns_topic_arn = 'arn:aws:sns:eu-west-1:762732311162:be-prod-email'

  ses.list_identities(max_items: 1000).identities.each do |identity|
    sleep 1

    notifications = get_notification_settings(identity)
    if  notifications.bounce_topic == sns_topic_arn &&
        notifications.complaint_topic == sns_topic_arn
      puts "SNS topics already set for #{identity}"
    else
      puts "Setting SNS topics for #{identity}..."

      %w(Bounce Complaint).each do |type|
        ses.set_identity_notification_topic({
          identity: identity,
          notification_type: type,
          sns_topic: sns_topic_arn
        })
      end
      ses.set_identity_feedback_forwarding_enabled({
        identity: identity,
        forwarding_enabled: false
      })
      puts "SNS topics set for #{identity}:"
      puts get_notification_settings(identity)
    end

  end
end

def ses
  @ses ||= Aws::SES::Client.new region: 'eu-west-1'
end

def get_notification_settings id
  ses.get_identity_notification_attributes({
   identities: [id]
  }).notification_attributes[id]
end

main
