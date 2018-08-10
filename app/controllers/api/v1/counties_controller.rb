module Api
  module V1
    class CountiesController < ApplicationController
      def index
          @state = State.find(params['state_id'])
          @office = OFfice.find(params['office_id'])
          render json: { state: @state, counties: @state.counties }
      end
    end
  end
end