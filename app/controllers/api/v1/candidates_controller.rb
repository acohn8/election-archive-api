module Api
  module V1
    class CandidatesController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: @state.candidates.order('id').distinct
      end

      def show
        @candidate = Candidate.find_by(normalized_name: params[:id])
        render json: @candidate
      end
    end
  end
end
