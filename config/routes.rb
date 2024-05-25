Rails.application.routes.draw do
  get 'usuarios/new'
  get 'usuarios/create'
  get 'portada/home'
  
  

  resources :usuarios, only: [:new, :create]  do 
    resources :anuncios, only: [:new, :create, :show]
  end

  root 'portada#home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
 
  # Defines the root path route ("/")
  # root "posts#index"
end
