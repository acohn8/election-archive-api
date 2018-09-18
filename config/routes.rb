Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :weathers
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
      get 'states/:state_id/offices/:office_id/results/district/:district_id/precinct/:county_id', to: 'results#render_county_district_precint_results'
      get 'states/:state_id/offices/:office_id/results/district/:district_id/county', to: 'results#congressional_district_results'
      get 'candidates/campaign-finance/:candidate_id', to: 'candidates#campaign_finance'
      get 'states/:state_id/offices/:office_id/candidates', to: 'results#office_candidates'
      get 'states/:state_id/offices/:office_id/results/state', to: 'results#state_results'
      get 'states/:state_id/offices/:office_id/results/district/:district_id', to: 'results#district_results'
      get 'states/:state_id/offices/:office_id/results/county', to: 'results#county_results'
      get 'states/:state_id/offices/:office_id/results/precinct/:county_id', to: 'results#precinct_results'
      get 'weathers/search/:link', to: 'weathers#show', constraints: { link: /[^\/]+/ }
      # get 'results/export/county/:state_id', to: 'results#county_export'
      # get 'results/export/precinct/:state_id', to: 'results#precinct_export'
    end
  end
end

