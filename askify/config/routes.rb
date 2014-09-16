Rails.application.routes.draw do
  resources :events, only: [:index, :show, :new, :create] do
    resources :questions, only: [:show, :new, :create]
  end

  root 'events#index'
end
