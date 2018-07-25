module Api
  module V1
    class PrecinctsController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: { state: @state, precincts: @state.precincts }
      end
    end
  end
end