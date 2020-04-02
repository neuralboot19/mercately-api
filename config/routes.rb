Rails.application.routes.draw do
  root to: 'pages#index'


  devise_for :retailer_users, path: '', path_names: {sign_up: 'register', sign_in: 'login',
    sign_out: 'logout'}, controllers: { registrations: 'retailer_users/registrations',
    sessions: 'retailer_users/sessions', passwords: 'retailer_users/passwords',
    omniauth_callbacks: 'retailer_users/omniauth_callbacks', invitations: 'retailer_users/invitations' }
  as :retailer_user do
    get 'retailers/:slug/edit', to: 'retailer_users/registrations#edit', as: :edit_retailer_info
    get 'retailers/:slug/team', to: 'retailers/settings#team', as: :edit_team
    post 'retailers/:slug/invite_team_member', to: 'retailers/settings#invite_team_member', as: :invite_team_member
    post 'retailers/:slug/reinvite_team_member', to: 'retailers/settings#reinvite_team_member', as: :reinvite_team_member
    post 'retailers/:slug/remove_team_member', to: 'retailers/settings#remove_team_member', as: :remove_team_member
    put 'retailers/:slug/reactive_team_member', to: 'retailers/settings#reactive_team_member', as: :reactive_team_member
    get 'retailers/:slug/api_key', to: 'retailers/settings#api_key', as: :api_key
    post 'retailers/:slug/generate_api_key', to: 'retailers/settings#generate_api_key', as: :generate_api_key
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get '/blog' => redirect("https://www.mercately.com/blog/")
  get '/privacidad', to: 'pages#privacy', as: :privacy
  get '/terminos', to: 'pages#terms', as: :terms
  get '/precios', to: 'pages#price', as: :pricing
  get '/crm', to: 'pages#crm', as: :crm


  namespace :retailers do
    namespace :api, defaults: { format: :json } do
      namespace :v1 do
        get 'ping', to: 'welcome#ping'
        post 'whatsapp/send_notification', to: 'karix_whatsapp#create'
      end
    end

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
      resources :customers, except: [:destroy]
      resources :messages, only: [:show]
      resources :templates
      put 'messages/:id/answer_question', to: 'messages#answer_question', as: :answer_question
      get 'integrations', to: 'integrations#index'
      #Facebook Chats
      get 'facebook_chats', to: 'messages#facebook_chats', as: :facebook_chats
      get 'facebook_chat/:id', to: 'messages#facebook_chat', as: :facebook_chat
      post 'facebook_chats/:id', to: 'messages#send_facebook_message', as: :send_facebook_message

      # WhatsApp Chats
      get 'whatsapp_chats', to: 'whats_app#index', as: :whats_app_chats

      get 'questions', to: 'messages#questions'
      get 'chats', to: 'messages#chats'
      get 'questions/:question_id', to: 'messages#question', as: :question
      put 'products/:id/archive', to: 'products#archive_product', as: :archive_product
      put 'products/:id/upload_product_to_ml', to: 'products#upload_product_to_ml', as: :upload_product_to_ml
      get 'questions_list', to: 'messages#questions_list'
      get 'pricing', to: 'payment_plans#index', as: :payment_plans
      post 'export_customers', to: 'customers#export', as: :export_customers
    end
    get 'integrations/mercadolibre', to: 'integrations#connect_to_ml'
    post 'callbacks', to: 'integrations#callbacks'
    get 'messenger_callbacks', to: 'integrations#messenger_callbacks'
    post 'messenger_callbacks', to: 'integrations#messenger_callbacks'
    get 'products/:id/product_with_variations', to: 'products#product_with_variations'
    get 'products/:id/price_quantity', to: 'products#price_quantity'
    get 'customers/:id', to: 'customers#customer_data'
    get 'templates/templates_for_questions', to: 'templates#templates_for_questions'
    get 'templates/templates_for_chats', to: 'templates#templates_for_chats'
    post 'plan_subscribe', to: 'payment_plans#subscribe', as: :plan_subscribe
  end

  put 'retailer_user/onboarding_status', to: 'retailer_users#update_onboarding_info', as: :update_onboarding_info

  get 'categories', to: 'categories#roots'
  get 'categories/:id', to: 'categories#childs', as: :categories_childs

  post 'request_demo', to: 'pages#request_demo', as: :request_demo

  # Dynamic error pages
  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_error"

  # REACT
  namespace :api do
    namespace :v1 do
      resources :customers, only: [:index, :show, :update]

      put 'customers/:id/assign_agent', to: 'agent_customers#update', as: :assign_agent

      get 'customers/:id/messages', to: 'customers#messages', as: :customer_messages
      post 'customers/:id/messages', to: 'customers#create_message', as: :create_message
      post 'customers/:id/messages/imgs', to: 'customers#send_img', as: :send_img
      post 'messages/:id/readed', to: 'customers#set_message_as_readed', as: :set_message_as_readed
      # For 360
      post 'whatsapp', to: 'whatsapp#create'
      # For Karix
      post 'karix_whatsapp', to: 'karix_whatsapp#save_message'
      post 'karix_send_whatsapp_message', to: 'karix_whatsapp#create'
      get 'karix_whatsapp_customers', to: 'karix_whatsapp#index', as: :karix_customers
      get 'karix_whatsapp_customers/:id/messages', to: 'karix_whatsapp#messages', as: :karix_customer_messages
      post 'karix_whatsapp_send_file/:id', to: 'karix_whatsapp#send_file', as: :karix_send_file
      put 'karix_whatsapp_update_message_read/:id', to: 'karix_whatsapp#message_read', as: :karix_message_read

      resources :karix_whatsapp, only: [:index, :create]
      resources :karix_whatsapp_templates, only: [:index]
    end
  end

  get '/:slug/:web_id', to: 'pages#product', as: :product_catalog
  get '/:slug', to: 'pages#catalog', as: :catalog
end
