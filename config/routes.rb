Rails.application.routes.draw do
  root 'pages#index'

  devise_for :retailer_users, controllers: { registrations: 'retailer_users/registrations',
    sessions: 'retailer_users/sessions' }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :retailers do
    scope '/:slug' do
      # get 'dashboard', to: 'pages#dashboard', as: :dashboard
      get 'dashboard', to: 'pages#dashboard', as: :dashboard
      resources :products
      resources :orders
      resources :customers
      resources :messages, only: [:index, :show]
      resources :templates
      put 'messages/:id/answer_question', to: 'messages#answer_question', as: :answer_question
      get 'integrations', to: 'integrations#index'
      get 'mercadolibre_import', to: 'integrations#mercadolibre_import'
    end
    get 'integrations/mercadolibre', to: 'integrations#connect_to_ml'
    post 'callbacks', to: 'integrations#callbacks'
  end

  get 'categories', to: 'categories#roots'
  get 'categories/:id', to: 'categories#childs', as: :categories_childs
end
