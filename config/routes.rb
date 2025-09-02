Rails.application.routes.draw do
  root "home#index"
  
  # Authentication routes
  resource :session
  resources :passwords, param: :token
  
  # Main application routes
  resources :vectors, only: [:index, :show]
  resources :pichia_strains, only: [:index, :show]
  
  # Cart routes
  resource :cart, only: [:show] do
    post :add_item
    patch :update_item
    delete :remove_item
    delete :clear
  end
  
  # Admin routes
  namespace :admin do
    root "dashboard#index"
    resources :vectors
    resources :pichia_strains
  end
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
