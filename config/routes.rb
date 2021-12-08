Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :trails, only: [ :index, :show ]
  resources :trips, only: [ :new, :create, :show ] do
    resources :steps
  end

  get "/dashboard", to: "pages#dashboard"

  post "/receive_sms", to: "messages#receive_sms"
end
