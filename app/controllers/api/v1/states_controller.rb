module Api
  module V1
    class StatesController < ApplicationController
      def index
        render json: State.all.order('name')
      end

      def show
        @state = State.find(params['id'])
        render json: @state
      end
    end
  end
end

