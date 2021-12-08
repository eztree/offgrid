Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [ :show ] do
    resources :emergency_contact, only: [ :new, :create ]
  end
  root to: 'pages#home'
  resources :trails, only: [ :index, :show ]
  resources :trips, only: [ :new, :create ] do
    resources :steps
  end
 get "/pages", to: "pages#dashboard"

end
