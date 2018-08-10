module Api
  module V1
    class CountiesController < ApplicationController
      def index
          @state = State.find(params['state_id'])
          render json: { state: @state, counties: @state.counties }
      end
    end
  end
end