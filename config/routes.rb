Rails.application.routes.draw do
  devise_for :users
  
  authenticated :user do
    root "uploads#index", as: :authenticated_root
  end
  
  root "home#index"
  
  resources :uploads, only: [:index, :new, :create, :show] do
    member do
      post :analyze_with_openai
    end
  end
  
  # Analyses/recommendations area
  get '/analyses', to: 'analyses#index', as: 'analyses'
  get '/analyses/:upload_id', to: 'analyses#show', as: 'analysis'
  post '/analyses/:upload_id/ask', to: 'analyses#ask_question', as: 'ask_analysis_question'
end