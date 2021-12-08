Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get "/dashboard", to: "pages#dashboard"

  resources :users, only: [:show] do
    resources :emergency_contacts, only: [:create]
  end

  resources :trails, only: [:index, :show]
  resources :trips, only: [:new, :create, :show]
  resources :steps

  post "/receive_sms", to: "messages#receive_sms"
end
