Rails.application.routes.draw do
  # root
  root 'pages#index'

  devise_for :retailers
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :products
end
