Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :states do
        resources :counties
        resources :districts
        resources :offices
        resources :precincts
        resources :results
        resources :candidates
      end
      get '/offices', to: 'offices#all_offices'
      get '/offices/:office_id', to: 'offices#show'
      get 'states/:state_id/offices/:office_id/results/district/:district_id', to: 'results#congressional_district_results'
      get 'states/:state_id/offices/:office_id/campaign-finance', to: 'offices#campaign_finance'
      get 'states/:state_id/offices/:office_id/candidates', to: 'results#office_candidates'
      get 'states/:state_id/offices/:office_id/results/state', to: 'results#state_results'
      get 'states/:state_id/offices/:office_id/results/county', to: 'results#county_results'
      get 'states/:state_id/offices/:office_id/results/precinct/:county_id', to: 'results#precinct_results'
      # get 'results/export/county/:state_id', to: 'results#county_export'
      # get 'results/export/precinct/:state_id', to: 'results#precinct_export'
    end
  end
end

