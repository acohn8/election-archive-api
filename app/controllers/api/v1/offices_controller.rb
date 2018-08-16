module Api
  module V1
    class OfficesController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: @state.offices.distinct.where(offices: { id: [309, 313, 308] })
      end

      def show
        @office = Office.find(params['office_id'])
        render json: @office
      end

      def all_offices
        render json: Office.find([309, 313, 308])
      end
    end
  end
end
