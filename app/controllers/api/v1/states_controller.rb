module Api
  module V1
    class StatesController < ApplicationController
      def index
        render json: State.render
      end

      def show
        @state = State.find(params[:id])
        if params[:id] == 'counties'
          render json: {counties: @state.counties }
        elsif params[:id] == 'precincts'
          render json: Precinct.render
        else
          render json: @state
        end
      end
    end
  end
end

