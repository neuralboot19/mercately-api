# Mercately

## Setting up the environment

Our environment:
* Ruby 2.5.3
* Rails 5.2.2
* PostgreSQL 11.1

## Tests
#### Branch naming convention
Please use one of these four prefixes for branch names: `feature/`, `test/`, `refactor/`, and `bug/`

#### Setup
 We're using Rspec for our tests and Capybara with Selenium for Integration testing; to run those test you can use any browser and webdriver.

 If you want to use Firefox:
 - Install Firefox
 - Download the [geckodriver](https://github.com/mozilla/geckodriver/releases)
   If you use linux do the following to install it: `sudo cp geckodriver /usr/bin` or `sudo cp geckodriver /usr/local/bin`
 - Go to `spec/rails_helper.rb` and change this:
  ```ruby
  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver :headless_chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w(headless disable-gpu) }
    )

    Capybara::Selenium::Driver.new app,
      browser: :chrome,
      desired_capabilities: capabilities
  end

  Capybara.javascript_driver = :headless_chrome
  ```

  To this:

  ```ruby
  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :firefox
  end
  ```
 - If you do this, **remember don't push up** `spec/rails_helper.rb` file

  If you want to use Chrome (we are using this by default):
  - Install Chrome
  - Download the [chromewebdriver](https://sites.google.com/a/chromium.org/chromedriver/downloads)
    If you use linux do the following to install it: `sudo cp geckodriver /usr/bin` or `sudo cp geckodriver /usr/local/bin`
