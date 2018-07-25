module Api
  module V1
    class ResultsController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: @state.render_state_results
      end

      def show
        @state = State.find(params['state_id'])
        if params[:id].split(' ').length == 1 && params[:id] =='county'
          render json: @state.render_state_county_results
        elsif params[:id].split(' ').length == 2 && params[:id].split(' ')[0] =='county'
          county_id =  params[:id].split(' ')[1].to_i
          @county = County.find(county_id)
          render json: @county.render_county_precint_results
        elsif params[:id].split(' ').length == 1 && params[:id] =='precinct'
          render json: @state.render_state_precint_results
        end
      end
    end
  end
end
