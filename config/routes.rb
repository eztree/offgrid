Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get "/pages", to: "pages#dashboard"
  resources :users, only: [:show] do
    resources :emergency_contacts, only: [:create]
  end
  resources :safety_records, only: [:new, :create]
  resources :trails, only: [:index, :show]
  resources :trips, only: [:new, :create, :show]
  resources :steps
end
