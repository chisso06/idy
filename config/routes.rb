Rails.application.routes.draw do
  root 'home#top'
  resources :users
end
