module Api
  module V1
    class PrecinctsController < ApplicationController
      def index
        # @state = State.find(params['state_id'])
        # render json: @state.render_precincts
        results = Result.where(state_id: params['state_id']).includes(:precinct, :candidate).where(candidate_id: [18, 14, 10, 12, 16]).order('precincts.name').group(['precincts.name', 'candidates.normalized_name']).sum(:total)
        formatted_results = results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
        render json: formatted_results
      end
    end
  end
end