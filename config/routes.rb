Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :trails, only: [ :index, :show ]

  get "/pages", to: "pages#dashboard"
end
