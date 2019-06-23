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
      config.dsn = 'https://6be9b8318da648a6acdb5504bcf04bbf:1277be5f12c64794ac4bf3f6e88997fd@sentry.io/1386758'
      config.environments = ['staging', 'production']
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.i18n.default_locale = :es

    config.action_view.field_error_proc = proc { |html_tag, instance| html_tag }
  end
end
