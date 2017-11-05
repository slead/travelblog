Rails.application.routes.draw do
  devise_for :users
  resources :photos
  resources :posts
  resources :contacts, only: [:new, :create]

  get '/about', to: 'content#about', as: :about #=> about_path
  get '/map', to: 'content#map', as: :map #=> map_path
  get '/subscribe', to: 'content#subscribe', as: :subscribe #=> subscribe_path
  match '/contact' => "contacts#new", via: [:get, :post], as: :contact
  get '/:id', to: 'posts#show', as: :post_path

  root to: "posts#index"
end
