Rails.application.routes.draw do
  root 'home#top'

  get "/login" => "users#login_form"
  post "/login" => "users#login"
  post "/logout" => "users#logout"

  resources :users
  resources :posts
  resources :likes
  resources :comments
end
