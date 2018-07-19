#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'

ELB = 'external-79c0d84762852697.elb.eu-central-1.amazonaws.com'
PATTERN = '.well-known/*'

def main
  ARGV.each do |distribution_id|
    resp = cf.get_distribution_config({id: distribution_id})
    config = resp.distribution_config.dup
    etag  = resp.etag
    changed = false

    if !config.origins.items.any? { |origin| origin.domain_name == ELB }
      config.origins.quantity += 1
      config.origins.items << {
        id: "elb", # required
        domain_name: ELB, # required
        origin_path: "",
        custom_headers: {
          quantity: 0
        },
        custom_origin_config: {
          http_port: 80, # required
          https_port: 443, # required
          origin_protocol_policy: "http-only", # required, accepts http-only, match-viewer, https-only
          origin_read_timeout: 30,
          origin_keepalive_timeout: 5,
          origin_ssl_protocols: {
            quantity: 2, # required
            items: %w[TLSv1.1 TLSv1.2], # required, accepts SSLv3, TLSv1, TLSv1.1, TLSv1.2
          }
        }
      }
      changed = true
    end

    if !config.cache_behaviors.items.any? { |behaviour| behaviour.path_pattern == PATTERN }
      config.cache_behaviors.quantity += 1
      config.cache_behaviors.items << {
        path_pattern: PATTERN, # required
        target_origin_id: "elb", # required
        forwarded_values: { # required
          query_string: false, # required
          cookies: { # required
            forward: "none", # required, accepts none, whitelist, all
            whitelisted_names: {
              quantity: 0 # required
            }
          },
          headers: {
            quantity: 1, # required
            items: ["*"]
          },
          query_string_cache_keys: {
            quantity: 0 # required
          }
        },
        trusted_signers: { # required
          enabled: false, # required
          quantity: 0 # required
        },
        viewer_protocol_policy: "allow-all", # required, accepts allow-all, https-only, redirect-to-https
        min_ttl: 0, # required
        allowed_methods: {
          quantity: 2, # required
          items: ["GET", "HEAD"], # required, accepts GET, HEAD, POST, PUT, PATCH, OPTIONS, DELETE
          cached_methods: {
            quantity: 2,    # required
            items: ["GET", "HEAD"]  # required, accepts GET, HEAD, POST, PUT, PATCH, OPTIONS, DELETE
          }
        },
        smooth_streaming: false,
        default_ttl: 0,
        max_ttl: 0,
        compress: false,
        lambda_function_associations: {
          quantity: 0 # required
        },
        field_level_encryption_id: ""
      }
      changed = true
    end
    if changed
      cf.update_distribution({
        distribution_config: config,
        id: distribution_id,
        if_match: etag
      })
      puts "#{distribution_id} updated"
      sleep 5
    else
      puts "Nothing changed for #{distribution_id}"
    end
  end
end


def cf
  @client ||= Aws::CloudFront::Client.new
end

main
