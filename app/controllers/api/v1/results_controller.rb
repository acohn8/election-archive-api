module Api
  module V1
    class ResultsController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: @state.render_counties
      end
    end
  end
end
