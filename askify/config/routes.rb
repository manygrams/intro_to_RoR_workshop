Rails.application.routes.draw do
  devise_for :users
  resources :events, only: [:index, :show, :new, :create] do
    resources :questions, only: [:show, :new, :create] do
      member do
        get 'upvote', controller: 'votes'
        get 'downvote', controller: 'votes'
      end
    end
  end

  root 'events#index'
end
