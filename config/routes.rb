Rails.application.routes.draw do
  root 'home#top'

  get "/email_authentication" => "account_activations#email_authentication"
  get "/send_email_again"     => "account_activations#send_email_again"

  post "/login"               => "users#login"
  post "/logout"              => "users#logout"

  get "/edit_email/:id"       => "users#edit_email_form"
  post "/edit_email/:id"      => "users#edit_email"
  get "/destroy/:id"          => "users#destroy_form"

  resources :users, expect: [:new, :edit, :index]
  resources :posts, expect: [:new, :edit] do
    resources :likes,             only: [:create, :destroy]
    resources :comments,          only: [:create, :destroy]
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :relationships,       only: [:create, :destroy]

  get '*path' => 'home#top'
end
