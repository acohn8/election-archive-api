module Api
  module V1
    class CountiesController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: @state.counties
      end

      def show
        @county = County.find(params['id'])
        render json: @county.county_info
      end
    end
  end
end