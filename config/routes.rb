Rails.application.routes.draw do
  resources :saml_metadata
  resource :dashboard, only: :show
  resources :user_sessions
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :saml do
    get "metadata" => "idp#show"
    get "auth" => "idp#new"
    post "auth" => "idp#create"
    match "logout" => "idp#logout", via: [ :get, :post, :delete ]
    get "attributes" => "idp#attributes"
  end

  root to: redirect("/dashboard")
end
