Rails.application.routes.draw do
  devise_for :retailer_owners
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :products
end
