module Api
  module V1
    class ResultsController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: @state.render_state_results
      end

      def show
        @state = State.find(params['state_id'])
        if params[:id] == 'county'
          render json: @state.render_county_results
        elsif params[:id] == 'precinct'
          render json: @state.render_precint_results
        end
      end
    end
  end
end
