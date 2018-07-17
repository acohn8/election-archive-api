Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :candidates
      resources :results
      resources :precincts
      resources :counties
      resources :states
    end
  end
end

