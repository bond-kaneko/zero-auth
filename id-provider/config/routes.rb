# config/routes.rb
Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # OIDC well-known endpoint (must be at root level per OIDC spec)
  get '/.well-known/openid-configuration', to: 'oidc/well_known#configuration'

  # OIDC endpoints
  namespace :oidc do
    get '/authorize', to: 'authorization#new'
    post '/authorize', to: 'authorization#create'
    post '/token', to: 'token#create'
    get '/userinfo', to: 'user_info#show'
    post '/userinfo', to: 'user_info#show'
    get '/jwks', to: 'jwks#index'
  end

  # Session management
  resources :sessions, only: [:new, :create, :destroy]
  get '/login', to: 'sessions#new', as: :login
  post '/logout', to: 'sessions#destroy', as: :logout

  # User registration
  resources :registrations, only: [:new, :create]
  get '/signup', to: 'registrations#new', as: :signup

  resource :user, only: [:show]

  # Root path (fallback for direct access to IdP)
  root 'sessions#new'
end