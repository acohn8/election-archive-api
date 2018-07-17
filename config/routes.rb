Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :states do
      resources :counties
      resources :precincts
    end
      resources :candidates
      resources :results
    end
  end
end

