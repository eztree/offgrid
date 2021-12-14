Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get "/dashboard", to: "pages#dashboard"
  get "/dashboard/mobile", to: "pages#dashboard_mobile"
  get "users/:user_id/trips/:id/checklist_mobile", to: "trips#checklist_mobile", as: "checklist_mobile"

  resources :users, only: [:show] do
    resources :emergency_contacts, only: [:create]
    resources :trips, only: [:show]
  end

  resources :trails, only: [:index, :show]
  resources :trips, only: [:new, :create, :show, :update]
  resources :checklists, only: [:update]
  resources :steps

  post "/receive_sms", to: "messages#receive_sms"

  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
