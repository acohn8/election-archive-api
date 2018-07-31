Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :states do
        resources :counties
        resources :precincts
        resources :results
        resources :candidates
      end
      get 'results/export/:state_id', to: 'results#export'
    end
  end
end

