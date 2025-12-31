Rails.application.routes.draw do
  devise_for :users

  # User profiles
  get "profile", to: "profiles#show", as: :my_profile
  get "u/:username", to: "profiles#show", as: :user_profile

  root "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :games, only: [:index, :show] do
    collection do
      get :random
    end
    member do
      post :play # Creates a new game session / saves the score
      post :vote # Like or dislike a game
      delete :vote, action: :unvote # Remove vote
    end
  end

  # Generator
  get "generator", to: 'generator#new'
  post "generator/preview", to: 'generator#preview'
  post "generator/create", to: 'generator#create'
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
