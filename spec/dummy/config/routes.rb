Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  # spec/dummy/config/routes.rb

  get '/my_action', to: 'fakes#my_action'
  get '/my_action_custom_status', to: 'fakes#my_action_custom_status'
  get '/my_action_pagination', to: 'fakes#my_action_pagination'

  get 'v1/fakes/my_action', to: 'v1/fakes#my_action'
end
