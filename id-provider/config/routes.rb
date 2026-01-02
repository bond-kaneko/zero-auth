# frozen_string_literal: true

# config/routes.rb
Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Root path (serves React SPA)
  root to: 'home#index'

  # OIDC well-known endpoint (must be at root level per OIDC spec)
  get '/.well-known/openid-configuration', to: 'oidc/well_known#configuration'

  # OIDC endpoints (standard paths per OIDC/OAuth 2.0 specification)
  namespace :oidc do
    get '/authorize', to: 'authorization#new'       # HTML: authorization page
    post '/authorize', to: 'authorization#create'   # Form submission
    post '/token', to: 'token#create'               # JSON API: token exchange
    get '/userinfo', to: 'user_info#show'           # JSON API: user info
    post '/userinfo', to: 'user_info#show'          # JSON API: user info (POST)
    get '/jwks', to: 'jwks#index'                   # JSON API: public keys
    get '/logout', to: 'authorization#destroy'      # RP-Initiated Logout
  end

  # HTML login page for OIDC authorization flow
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'

  # HTML signup page
  get '/signup', to: 'registrations#new'
  post '/signup', to: 'registrations#create'

  # JSON API endpoints for React SPA
  namespace :api do
    # Session management for IdP itself
    resources :sessions, only: %i[create destroy]

    # User registration
    resources :registrations, only: [:create]

    # Current user info
    resource :user, only: [:show]

    # Management API for admin features
    namespace :management do
      resources :clients, only: %i[index show create update destroy] do
        member do
          post :revoke_secret
        end
      end
      resources :users, only: %i[index show create update destroy]
    end
  end
end
