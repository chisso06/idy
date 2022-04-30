Rails.application.routes.draw do
  root 'home#top'

  get "/login" => "users#login_form"
  post "/login" => "users#login"
  post "/logout" => "users#logout"

  get "/likes/index/:post_id" => "likes#index"
  post "/likes/new/:post_id" => "likes#create"
  delete "/likes/:post_id" => "likes#destroy"

  resources :users
  resources :posts
end
