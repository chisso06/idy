Rails.application.routes.draw do
  root 'home#top'

  get "/login" => "users#login_form"
  post "/login" => "users#login"
  post "/logout" => "users#logout"

  get "/destroy" => "users#destroy_form"

  resources :users
  resources :posts do
    resources :likes
    resources :comments
  end
end
