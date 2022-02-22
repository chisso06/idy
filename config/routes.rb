Rails.application.routes.draw do
  root 'home#top'

  get "/login" => "users#login_form"
  post "/login" => "users#login"

  resources :users
end
