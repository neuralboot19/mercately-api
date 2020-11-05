require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'pages#index'

  constraints lambda { |request|
    request.env['warden'].authenticate!({ scope: :admin_user })
  } do
    mount Sidekiq::Web => '/sidekiq'
  end

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
    post 'retailers/:slug/set_admin_team_member', to: 'retailers/settings#set_admin_team_member', as: :set_admin_team_member
    post 'retailers/:slug/set_agent_team_member', to: 'retailers/settings#set_agent_team_member', as: :set_agent_team_member
    post 'retailers/:slug/set_supervisor_team_member', to: 'retailers/settings#set_supervisor_team_member', as: :set_supervisor_team_member
    put 'retailers/:slug/reactive_team_member', to: 'retailers/settings#reactive_team_member', as: :reactive_team_member
    get 'retailers/:slug/api_key', to: 'retailers/settings#api_key', as: :api_key
    post 'retailers/:slug/generate_api_key', to: 'retailers/settings#generate_api_key', as: :generate_api_key
  end

  devise_scope :retailer_user do
    get '/retailer_users/auth/facebook/messenger', to: 'retailer_users/omniauth_callbacks#messenger', as: :retailer_user_omniauth_messenger
    get '/retailer_users/auth/facebook/catalog', to: 'retailer_users/omniauth_callbacks#catalog', as: :retailer_user_omniauth_catalog
    get 'auth/facebook/setup', to: 'retailer_users/omniauth_callbacks#setup'
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get '/privacidad', to: 'pages#privacy', as: :privacy
  get '/terminos', to: 'pages#terms', as: :terms
  get '/whatsapp-crm', to: 'pages#whatsapp_crm', as: :whatsapp_crm

  namespace :retailers do
    namespace :api, defaults: { format: :json } do
      namespace :v1 do
        get 'ping', to: 'welcome#ping'
        post 'whatsapp/send_notification', to: 'karix_whatsapp#create'
      end
    end

    scope '/:slug' do
      get 'dashboard', to: 'pages#dashboard', as: :dashboard
      get 'business_config', to: 'pages#business_config', as: :business_config
      get 'total_messages_stats', to: 'stats#total_messages_stats', as: :total_messages_stats
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
      get 'import', to: 'customers#import', as: :customers_import
      post 'export_customers', to: 'customers#export', as: :export_customers
      post 'bulk_import', to: 'customers#bulk_import', as: :customers_bulk_import
      get 'manage_automatic_answers', to: 'automatic_answers#manage_automatic_answers', as: :manage_automatic_answers
      post 'save_automatic_answer', to: 'automatic_answers#save_automatic_answer', as: :save_automatic_answer
      get 'select_catalog', to: 'facebook_catalogs#select_catalog'
      put 'save_selected_catalog', to: 'facebook_catalogs#save_selected_catalog', as: :save_selected_catalog
      post 'payment_methods/create-setup-intent', to: 'payment_methods#create_setup_intent', as: :payment_create_setup_intent
      resources :payment_methods, only: [:create, :destroy]
      resources :paymentez, only: [:create, :destroy] do
        collection do
          post :add_balance
          post :purchase_plan
        end
      end
      resources :tags

      resources :sales_channels
      resources :chat_bots, except: [:destroy] do
        get 'list_chat_bot_options', to: 'chat_bots#list_chat_bot_options', as: :list_chat_bot_options
        get 'new_chat_bot_option', to: 'chat_bots#new_chat_bot_option', as: :new_chat_bot_option
        get 'edit_chat_bot_option', to: 'chat_bots#edit_chat_bot_option', as: :edit_chat_bot_option
        post 'delete_chat_bot_option', to: 'chat_bots#delete_chat_bot_option', as: :delete_chat_bot_option
      end
      resources :team_assignments
      resources :stats, only: :index
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
    get 'chat_bots/:id/tree_options', to: 'chat_bots#tree_options', as: :chat_bot_tree_options
    get 'chat_bots/:id/path_option', to: 'chat_bots#path_option', as: :chat_bot_path_option
  end

  put 'retailer_user/onboarding_status', to: 'retailer_users#update_onboarding_info', as: :update_onboarding_info

  get 'categories', to: 'categories#roots'
  get 'categories/:id', to: 'categories#childs', as: :categories_childs

  post 'request_demo', to: 'pages#request_demo', as: :request_demo

  # Dynamic error pages
  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_error"

  # Gupshup callback
  post 'gupshup/ws', to: 'gupshup_whatsapp#save_message'

  # Stripe callback
  post 'stripe/webhook', to: 'stripe#webhook'

  # REACT
  namespace :api do
    namespace :v1 do
      resources :customers, only: [:index, :show, :update]

      put 'customers/:id/assign_agent', to: 'agent_customers#update', as: :assign_agent

      get 'customers/:id/messages', to: 'customers#messages', as: :customer_messages
      post 'customers/:id/messages', to: 'customers#create_message', as: :create_message
      post 'customers/:id/messages/imgs', to: 'customers#send_img', as: :send_img
      post 'messages/:id/read', to: 'customers#set_message_as_read', as: :set_message_as_read
      post 'customers/:id/messages/send_bulk_files', to: 'customers#send_bulk_files', as: :send_bulk_files
      # For 360
      post 'whatsapp', to: 'whatsapp#create'

      # App Mobile
      get 'ping', to: 'welcome#ping', as: :ping
      post 'sign_in', to: 'sessions#create', as: :sign_in
      delete 'log_out', to: 'sessions#delete', as: :log_out

      # For Karix
      post 'karix_whatsapp', to: 'karix_whatsapp#save_message'
      post 'karix_send_whatsapp_message', to: 'karix_whatsapp#create'
      get 'karix_whatsapp_customers', to: 'karix_whatsapp#index', as: :karix_customers
      get 'karix_whatsapp_customers/:id/messages', to: 'karix_whatsapp#messages', as: :karix_customer_messages
      post 'karix_whatsapp_send_file/:id', to: 'karix_whatsapp#send_file', as: :karix_send_file
      put 'whatsapp_update_message_read/:id', to: 'karix_whatsapp#message_read', as: :karix_message_read
      patch 'whatsapp_unread_chat/:id', to: 'karix_whatsapp#set_chat_as_unread', as: :set_chat_as_unread
      post 'karix_whatsapp_send_bulk_files/:id', to: 'karix_whatsapp#send_bulk_files', as: :karix_send_bulk_files

      resources :karix_whatsapp, only: [:index, :create]
      resources :whatsapp_templates, only: [:index]
      resources :products, only: [:index]

      get 'fast_answers_for_messenger', to: 'customers#fast_answers_for_messenger'
      patch 'accept_optin_for_whatsapp/:id', to: 'customers#accept_opt_in',  as: :accept_optin_for_whatsapp
      get 'fast_answers_for_whatsapp', to: 'karix_whatsapp#fast_answers_for_whatsapp'

      get 'customers/:id/selectable_tags', to: 'customers#selectable_tags', as: :selectable_tags
      post 'customers/:id/add_customer_tag', to: 'customers#add_customer_tag', as: :add_customer_tag
      delete 'customers/:id/remove_customer_tag', to: 'customers#remove_customer_tag', as: :remove_customer_tag
      post 'customers/:id/add_tag', to: 'customers#add_tag', as: :add_tag
      put 'customers/:id/toggle_chat_bot', to: 'customers#toggle_chat_bot', as: :toggle_chat_bot
    end
  end

  get '/blog', to: 'blogs#index', as: :blog
  get '/blog/:id', to: 'blogs#show', as: :blog_content
  get '/:slug/:web_id', to: 'pages#product', as: :product_catalog
  get '/:slug', to: 'pages#catalog', as: :catalog
end
