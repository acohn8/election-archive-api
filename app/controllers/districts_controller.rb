module Api
  module V1
    class DistrictsController < ApplicationController
      def index
        @state = State.find(params[:state_id])
        render json: @state.districts
      end
    end
  end
end
