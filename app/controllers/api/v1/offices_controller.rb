module Api
  module V1
    class OfficesController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: @state.offices
      end

      def show
        @office = Office.find(params['office_id'])
        render json: @office
      end

      def all_offices
        render json: Office.find([309, 313, 308, 322])
      end

      def campaign_finance
        # @office = Office.find(params['office_id'])
        @state = State.find(params['state_id'])
        @state.get_campaign_finance_data
      end
    end
  end
end
