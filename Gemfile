source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

gem 'rails', '~> 5.2.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

gem 'coffee-rails', '~> 4.2'
# gem 'jbuilder', '~> 2.5'
gem 'bootsnap', '>= 1.1.0', require: false
# gem 'redis', '~> 4.0'
# gem 'bcrypt', '~> 3.1.7'

# Send error logs
gem 'sentry-raven', '~> 2.9'

# Login and administration
gem 'activeadmin', '~> 1.4', '>= 1.4.3'
gem 'devise', '~> 4.6', '>= 4.6.1'
gem 'omniauth-facebook', '~> 5.0'
gem 'faraday', '~> 0.15.4'
gem 'cocoon', '~> 1.2', '>= 1.2.12'
gem 'ancestry', '~> 3.0', '>= 3.0.5'

# Pagination
gem 'kaminari', '~> 1.1', '>= 1.1.1'

# Img upload
gem 'cloudinary', require: false
gem 'activestorage-cloudinary-service'

gem "rack-reverse-proxy", require: "rack/reverse_proxy"

# FontAwesome
gem 'font_awesome5_rails', '~> 0.8.0'

gem 'select2-rails'
gem 'scout_apm'
gem 'chartkick', '~> 3.2.2'
gem 'groupdate', '~> 4.2'
gem 'active_model_serializers', '~> 0.10.0'

# Datepicker
gem 'jquery-rails'
gem 'momentjs-rails'
gem 'bootstrap-daterangepicker-rails', '~> 3.0.4'

# WebPack
gem 'webpacker', '~> 4.2'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8', '>= 3.8.2'
  gem 'rubocop-rspec', '~> 1.33'
  gem 'factory_bot_rails', '~> 5.0', '>= 5.0.1'
  gem 'faker'
  gem 'dotenv-rails'
  gem 'async'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rb-readline'
end

group :test do
  gem 'vcr', '~> 5.0'
  gem 'webmock', '~> 3.7'
  gem 'simplecov', require: false
  gem 'shoulda-matchers', '~> 4.1'
  gem 'rails-controller-testing', '~> 0.0.3'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Link stylesheets to actionmailer
gem 'premailer-rails'

gem 'mini_magick'

gem 'sidekiq'
