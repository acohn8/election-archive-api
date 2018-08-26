module Api
  module V1
    class CandidatesController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        render json: @state.candidates.order('id')
      end

      def campaign_finance
        @candidates = Candidate.find(params['candidate_id'].split(','))
        render json: Candidate.get_campaign_finance_data(@candidates)
      end
    end
  end
end
