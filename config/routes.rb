Rails.application.routes.draw do
  get "gems/index"
  get "gems/show"

  # Mount Solid Queue web UI if needed in the future
  # mount SolidQueue::Engine => "/solid_queue" if defined?(SolidQueue::Engine)

  resources :gemfiles do
    member do
      post "favorite", to: "gemfiles#favorite"
      delete "unfavorite", to: "gemfiles#unfavorite"
      get "gems_details", to: "gemfiles#gems_details"
    end
  end

  resources :gems

  get "/top-gems", to: "pages#top_gems"

  # Authentication
  get "auth/github/callback", to: "sessions#create"
  get "auth/failure", to: "sessions#failure"
  delete "sign_out", to: "sessions#destroy"

  get "search", to: "search#index"

  namespace :my do
    resources :favorites, only: [ :index ]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "gemfiles#index"
end
