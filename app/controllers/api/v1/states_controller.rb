module Api
  module V1
    class StatesController < ApplicationController
      def index
        render json: State.render
      end

      def show
        if params[:id] == 'counties'
          render json: County.render
        elsif params[:id] == 'precincts'
          render json: Precinct.render
        else
          @state = State.find(params[:id])
          render json: @state.render_show
        end
      end
    end
  end
end

