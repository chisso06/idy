Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  root 'home#top'

  get "/email_authentication" => "account_activations#email_authentication"
  get "/send_email_again" => "account_activations#send_email_again"

  get "/login" => "users#login_form"
  post "/login" => "users#login"
  post "/logout" => "users#logout"

  get "/edit_email/:id" => "users#edit_email_form"
  post "/edit_email/:id" => "users#edit_email"
  get "/destroy/:id" => "users#destroy_form"

  resources :users
  resources :posts do
    resources :likes
    resources :comments
  end
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
end
