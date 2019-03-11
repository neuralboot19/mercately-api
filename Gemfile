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
gem 'simple_form'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8', '>= 3.8.2'
  gem 'rubocop-rspec', '~> 1.32'
  gem 'factory_bot_rails', '~> 5.0', '>= 5.0.1'
  gem 'faker'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
