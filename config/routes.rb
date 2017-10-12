Rails.application.routes.draw do
  resources :posts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/about', to: 'content#about', as: :about #=> about_path 
  get '/contact', to: 'content#contact', as: :contact #=> contact_path 
  root to: "posts#index"
end
