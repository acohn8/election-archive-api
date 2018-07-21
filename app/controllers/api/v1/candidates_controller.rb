module Api
  module V1
    class CandidatesController < ApplicationController
      def index
        render json: Candidate.all.distinct
      end

      def show
        @candidate = Candidate.find_by(normalized_name: params[:id])
        render json: @candidate
      end
    end
  end
end
