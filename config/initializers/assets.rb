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
  retailers/stripe/stripe.js
  dashboard.js
  catalog.js
  catalog.css
  retailers/chat_bots/chat_bots.js
)
Rails.application.config.assets.css_compressor = :sass
