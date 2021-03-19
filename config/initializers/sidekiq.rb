Sidekiq.configure_server do |config|
  config.redis = if ENV['ENVIRONMENT'] == 'production'
                   { url: 'redis://redis.mercately.com:6379/12' }
                 else
                   { url: 'redis://localhost:6379/12' }
                 end
end

Sidekiq.configure_client do |config|
  config.redis = if ENV['ENVIRONMENT'] == 'production'
                   { url: 'redis://redis.mercately.com:6379/12' }
                 else
                   { url: 'redis://localhost:6379/12' }
                 end
end
