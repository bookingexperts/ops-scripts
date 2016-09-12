# run it remotely with ruby -e "$(curl -fsSL https://raw.github.com/bookingexperts/ops-scripts/master/deploy/elastic_beanstalk.rb)"
#
# Credits to SemaphoreCI.
# We took inspiration from their beanstalk deploy script.

require 'date'

# Deploy to AWS ElasticBeanstalk, http://aws.amazon.com/elasticbeanstalk/

# Environment variables configuration

# AWS_DEFAULT_REGION    - for example eu-central-1
# AWS_SECRET_ACCESS_KEY - aws secret key, should have elastic beanstalk rights
# AWS_ACCESS_KEY_ID     - aws access key
# S3_BUCKET_NAME        - bucket to store the zipped code
# EB_ENV_NAMES          - one or more environments delimited by a white space, for example 'staging-app staging-worker'
# EB_APP_NAME           - name of the application

%w(
  aws_default_region
  aws_secret_access_key
  aws_access_key_id
  s3_bucket_name
  eb_env_names
  eb_app_name
).each do |var|
  if !(value = ENV[var.upcase]).nil?
    eval "@#{var} = '#{value}'"
  else
    raise "You need to configure the #{var.upcase} environment variable!"
  end
end

# Generate defaults
@version_name = [
  `git rev-parse --short HEAD`.strip,
  DateTime.now.strftime('%Y-%m-%d_%H_%M_%S')
].join('_')
@version_desc = `git show -s --format=%s HEAD`.strip.gsub('"', "'")
@version_file_name = "#{@version_name}.zip"
@s3_key = "#{@eb_app_name}/#{@version_file_name}"

# Use git archive - not suitable for creating assets while deploying like `rake assets:precompile`
puts "Zipping your code to #{@version_file_name}"
`git archive -o "#{@version_file_name}" HEAD`

puts "Uploading to s3://#{@s3_bucket_name}/#{@s3_key}"
`aws s3 cp #{@version_file_name} s3://#{@s3_bucket_name}/#{@s3_key}`

puts "Create new application version: #{@version_name}"
`aws elasticbeanstalk create-application-version --application-name #{@eb_app_name} --version-label #{@version_name} --source-bundle S3Bucket=#{@s3_bucket_name},S3Key="#{@s3_key}" --description "#{@version_desc}"`

@failed_deploys = []
@threads = []

@eb_env_names.split(' ').each_with_index do |eb_env_name, eb_env_index|

  thread = Thread.new do
    puts "#{eb_env_name}: Start update"
    `aws elasticbeanstalk update-environment --environment-name #{eb_env_name} --version-label #{@version_name}`

    # commands

    env_describe_cmd  = %Q(aws elasticbeanstalk describe-environments --environment-names #{eb_env_name})
    env_status_cmd    = %Q(#{env_describe_cmd} | grep '"Status"' | cut -d: -f2  | sed -e 's/^[^"]*"//' -e 's/".*$//')
    env_version_cmd   = %Q(#{env_describe_cmd} | grep VersionLabel | cut -d: -f2 | sed -e 's/^[^"]*"//' -e 's/".*$//')
    env_color_cmd     = %Q(#{env_describe_cmd} | grep '"Health":' | cut -d: -f2  | sed -e 's/^[^"]*"//' -e 's/".*$//')

    puts "#{eb_env_name}: " + `#{env_status_cmd}`.strip

    while `#{env_status_cmd}`.strip == 'Updating' do
      sleep 5
    end

    if `#{env_version_cmd}`.strip == @version_name
      puts "#{eb_env_name}: The version of application code on Elastic Beanstalk matches the version sent in this deployment."
    else
      @failed_deploys << eb_env_name
      puts "#{eb_env_name}: The version of application code on Elastic Beanstalk does not match the version sent in this deployment. Please check your AWS Elastic Beanstalk Console for more information."
      puts `#{env_describe_cmd}`.strip
    end

    sleep 5

    tries = 0
    healthy = false
    while !(healthy = %w(Green Yellow).include?(`#{env_color_cmd}`.strip)) and tries < 30 do
      sleep 2
      tries += 1
    end

    if healthy
      puts "#{eb_env_name}: Your environment status is healthy, congrats!"
    else
      @failed_deploys << eb_env_name
      puts "#{eb_env_name}: Your environment status is not healthy, sorry."
      puts `#{env_describe_cmd}`.strip
    end
  end

  if eb_env_index == 0
    # Let's wait for the first environment to complete.
    # The first environment should be the one that runs database migrations etc.
    # You don't want the other environments to be completed before the migrations are completed.
    thread.join
  else
    @threads << thread
  end

end

# Wait for the other threads to finish
@threads.each {|tr| tr.join }

if @failed_deploys.empty?
  puts "All deploys were successfull"
  exit true
else
  puts "The following environments failed to deploy: #{@failed_deploys.uniq.join(', ')}"
  exit false
end
