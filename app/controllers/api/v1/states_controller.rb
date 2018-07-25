module Api
  module V1
    class StatesController < ApplicationController
      def index
        render json: State.all.order('name')
      end

      def show
        @state = State.find(params[:id])
        if params[:id] == 'counties'
          render json: {counties: @state.counties }
        elsif params[:id] == 'precincts'
          byebug
          render json: { precincts: @state.precincts }
        else
          render json: @state
        end
      end
    end
  end
end

