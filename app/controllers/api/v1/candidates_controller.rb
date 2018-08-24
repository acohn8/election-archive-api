module Api
  module V1
    class CandidatesController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: @state.candidates.order('id').distinct
      end

      def campaign_finance
        @candidate = Candidate.find(params['candidate_id'])
        render json: @candidate.get_campaign_finance_data
      end
    end
  end
end
