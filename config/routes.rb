Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  namespace :management do
    resource :site
    resources :saml_metadata
    resource :dashboard, only: :show
    resources :user_sessions
    resources :users
    resource :account, only: %i[show edit update]

    root to: "dashboard#show"
  end
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
    resource :metadata, only: :show
    get "metadata"
    namespace :sp do # When acting as Service Provider
      get "acs"
      post "acs"
      get "slo"
      post "slo"
    end
    namespace :idp do # When acting as Identity Provider
      get "sso"
      post "sso"
      get "slo"
      post "slo"
    end
    namespace :authn_authority do # When acting as Authn Authority
      resource :query, only: :create   # AuthnQuery endpoint
    end
    namespace :attribute_authority do # When acting as Attribute Authority
      resource :query, only: :create   # AttributeQuery endpoint
    end
  end

  namespace :saml do
    get "metadata" => "idp#show"
    get "metadata2" => "idp#metadata"
    get "auth" => "idp#new"
    post "auth" => "idp#create"
    match "logout" => "idp#logout", via: %i[get post delete]
    get "attributes" => "idp#attributes"
  end

  root to: redirect("/management/dashboard")
end
