Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get '/auth/login', to: 'auth#login'
  get '/auth/callback', to: 'auth#callback'
end
