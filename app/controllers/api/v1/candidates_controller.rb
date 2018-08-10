module Api
  module V1
    class CandidatesController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: @state.candidates.order('id').distinct
      end
    end
  end
end
