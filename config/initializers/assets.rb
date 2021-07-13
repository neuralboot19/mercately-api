# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.

Rails.application.config.assets.precompile += %w(
  .svg
  flexboxgrid.css
  retailer.css
  retailers/products.js
  mailers/welcome_mailer.css
  orders/orders.js
  landing/index.js
  new_dashboard.css
  retailers/templates/templates.js
  retailers/questions/questions.js
  retailers/customers/customers.js
  retailers/customers/reminders.js
  retailers/stripe/stripe.js
  retailers/paymentez/paymentez.js
  retailers/payment_plans/payment_plans.js
  dashboard.js
  catalog.js
  catalog.css
  retailers/chat_bots/chat_bots.js
  blogs.css
  blogs
  pages.css
  pages.js
  retailers/team_assignments/team_assignments.js
  vendor/assets
  fullcalendar/main.css
  full_calendar.css
  retailers/gs_templates/gs_templates.js
  chats/chat.js
  chats/chat.css
)
Rails.application.config.assets.css_compressor = :sass
