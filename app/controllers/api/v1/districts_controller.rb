module Api
  module V1
    class DistrictsController < ApplicationController
      def state_office_districts
        @state = State.find(params[:state_id])
        @office = Office.find(params[:office_id])
        render json: District.joins(:results).where(results: { state_id: @state.id, office_id: @office.id }).distinct
      end
    end
  end
end
