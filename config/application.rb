require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mercately
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.autoload_paths += %W(\#{config.root}/lib)

    config.generators do |g|
      g.test_framework :rspec, view_specs: false
      g.stylesheets false
      g.javascripts false
    end

    Raven.configure do |config|
      config.dsn = 'https://d83a4c9f783e44a0871416e565f38e4a:e73cd5c4fde44f909bbef10fd9d050aa@sentry.io/1767402'
      config.environments = %w(staging production)
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.action_view.field_error_proc = proc { |html_tag, instance| html_tag }

    config.active_job.queue_adapter = :sidekiq

    # Reverse Proxy for Blog
    config.middleware.insert(0, Rack::ReverseProxy) do
      reverse_proxy_options preserve_host: true
      reverse_proxy(/^\/blog(\/.*)$/, 'https://blog.mercately.com$1')
    end
  end
end
