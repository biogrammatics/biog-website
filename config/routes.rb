Rails.application.routes.draw do
  root "home#index"

  # Authentication routes
  resource :session
  resources :passwords, param: :token

  # Main application routes
  resources :vectors, only: [ :index, :show ]
  resources :pichia_strains, only: [ :index, :show ]

  # Custom Projects routes
  resources :custom_projects do
    collection do
      get :protein_expression
      post :protein_expression
    end
    member do
      patch :approve_dna_sequence
      patch :reject_dna_sequence
    end
  end

  # Cart routes
  resource :cart, only: [ :show ], controller: "cart" do
    post :add_item
    patch :update_item
    delete :remove_item
    delete :clear
    post :checkout
  end

  # Subscription routes
  resources :subscriptions, only: [ :index, :show, :new, :create ] do
    member do
      post :add_vector
    end
  end

  # Checkout routes
  resources :checkout, only: [:new, :create] do
    collection do
      get :address_step
      post :address_step
      get :payment_step
      post :payment_step
      get :review_step
      post :review_step
      get :confirmation
    end
  end

  # Account page
  get "account", to: "account#show"

  # Admin routes
  namespace :admin do
    root "dashboard#index"
    resources :vectors
    resources :pichia_strains
    resources :custom_projects do
      member do
        patch :update_status
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
