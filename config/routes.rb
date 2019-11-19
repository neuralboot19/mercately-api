Rails.application.routes.draw do
  root 'pages#index'

  devise_for :retailer_users, path: '', path_names: {sign_up: 'register', sign_in: 'login',
    sign_out: 'logout'}, controllers: { registrations: 'retailer_users/registrations',
    sessions: 'retailer_users/sessions', passwords: 'retailer_users/passwords' }
  as :retailer_user do
    get 'retailers/:slug/edit', to: 'retailer_users/registrations#edit', as: :edit_retailer_info
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get '/blog' => redirect("https://www.mercately.com/blog/")

  get '/privacidad', to: 'pages#privacy', as: :privacy
  get '/terminos', to: 'pages#terms', as: :terms

  namespace :retailers do
    scope '/:slug' do
      get 'dashboard', to: 'pages#dashboard', as: :dashboard
      resources :products do
        member do
          put 'reactive', to: 'products#reactive_product', as: :reactivate_product
          put 'update_meli_status', to: 'products#update_meli_status'
        end
      end
      resources :orders do
        get 'messages', to: 'messages#chat'
        post 'send_message', to: 'messages#send_message', as: :send_message
      end
      resources :customers, except: [:destroy, :show]
      resources :messages, only: [:show]
      resources :templates
      put 'messages/:id/answer_question', to: 'messages#answer_question', as: :answer_question
      get 'integrations', to: 'integrations#index'
      get 'questions', to: 'messages#questions'
      get 'chats', to: 'messages#chats'
      get 'questions/:question_id', to: 'messages#question', as: :question
      put 'products/:id/archive', to: 'products#archive_product', as: :archive_product
      put 'products/:id/upload_product_to_ml', to: 'products#upload_product_to_ml', as: :upload_product_to_ml
    end
    get 'integrations/mercadolibre', to: 'integrations#connect_to_ml'
    post 'callbacks', to: 'integrations#callbacks'
    get 'products/:id/product_with_variations', to: 'products#product_with_variations'
    get 'products/:id/price_quantity', to: 'products#price_quantity'
    get 'customers/:id', to: 'customers#customer_data'
    get 'templates/templates_for_questions', to: 'templates#templates_for_questions'
    get 'templates/templates_for_chats', to: 'templates#templates_for_chats'
  end

  put 'retailer_user/onboarding_status', to: 'retailer_users#update_onboarding_info', as: :update_onboarding_info

  get 'categories', to: 'categories#roots'
  get 'categories/:id', to: 'categories#childs', as: :categories_childs

  post 'request_demo', to: 'pages#request_demo', as: :request_demo

  # Dynamic error pages
  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_error"
end
