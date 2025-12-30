# config/routes.rb
Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # OIDC endpoints
  namespace :oidc do
    get '/.well-known/openid-configuration', to: 'well_known#configuration'
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
end