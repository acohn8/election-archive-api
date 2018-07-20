module Api
  module V1
    class CountiesController < ApplicationController
      def index
          @state = State.find(params['state_id'])

          render json: @state.render_counties

          # render json: @state.render_counties
          # render json: @state.as_json(
          #   only: :name,
          #   include: { counties: { only: [:name, :fips]}, include: {:candidates }})

      end
    end
  end
end