Rails.application.routes.draw do
  resources :events do
    resources :questions
  end

  root 'events#index'
end
