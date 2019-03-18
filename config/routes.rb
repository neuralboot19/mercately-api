Rails.application.routes.draw do
  root 'pages#index'

  devise_for :retailer_users, controllers: { registrations: 'retailer_users/registrations' }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get 'retailers/:slug/dashboard', to: 'retailers#dashboard', as: :retailers_dashboard

  namespace :retailers do
    resources :products
    resources :customers
  end
end
