Rails.application.routes.draw do
  root 'pages#index'

  devise_for :retailer_users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :retailers do
    resources :products
    resources :customers
  end
end
