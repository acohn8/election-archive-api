Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :states do
        resources :counties
        resources :offices
        resources :precincts
        resources :results
        resources :candidates
      end
      get '/offices', to: 'offices#all_offices'
      get 'states/:state_id/offices/:office_id/candidates', to: 'results#office_candidates'
      get 'states/:state_id/offices/:office_id/results/state', to: 'results#state_results'
      get 'states/:state_id/offices/:office_id/results/county', to: 'results#county_results'
      get 'states/:state_id/offices/:office_id/results/precinct/:county_id', to: 'results#precinct_results'
      # get 'results/export/county/:state_id', to: 'results#county_export'
      # get 'results/export/precinct/:state_id', to: 'results#precinct_export'
    end
  end
end

