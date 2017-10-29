Rails.application.routes.draw do
  devise_for :users
  resources :photos
  resources :posts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/about', to: 'content#about', as: :about #=> about_path
  get '/map', to: 'content#map', as: :map #=> map_path
  get '/subscribe', to: 'content#subscribe', as: :subscribe #=> subscribe_path
  get '/:id', to: 'posts#show', as: :post_path

  root to: "posts#index"
end
