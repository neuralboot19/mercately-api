Rails.application.routes.draw do
  root 'pages#index'

  devise_for :retailer_users, controllers: { registrations: 'retailer_users/registrations' }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :retailers do
    scope '/:slug' do
      get 'dashboard', to: 'pages#dashboard', as: :retailers_dashboard
      resources :products
      resources :orders
      resources :customers
      get 'integrations', to: 'integrations#index'
    end
    get 'integrations/mercadolibre', to: 'integrations#connect_to_ml'
  end
end
