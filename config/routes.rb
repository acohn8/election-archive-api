Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :states do
        resources :counties
        resources :precincts
        resources :results
        resources :candidates
      end
      get 'results/export/county/:state_id', to: 'results#county_export'
      get 'results/export/precinct/:state_id', to: 'results#precinct_export'
    end
  end
end

