require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
# Bundler.require(*Rails.groups)
Bundler.require(:default, Rails.env)

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

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.action_view.field_error_proc = proc { |html_tag, instance| html_tag }

    config.active_job.queue_adapter = :sidekiq

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '/retailers/api/v1/*', headers: :any, methods: [:get, :post, :put, :patch, :delete]
      end
    end

    # Reverse Proxy for Blog
    config.middleware.insert(0, Rack::ReverseProxy) do
      reverse_proxy_options preserve_host: true
      reverse_proxy(/^\/blog(\/.*)$/, 'https://blog.mercately.com$1')
    end

    config.generators do |g|
      g.orm :active_record
    end
  end
end
