Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :trails, only: [ :index, :show ] do
  end
  resources :trips, only: [ :new, :create ]
  resources :steps
end
