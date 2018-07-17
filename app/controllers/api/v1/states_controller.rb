module Api
  module V1
    class StatesController < ApplicationController
      def index
        render json: State.render
      end
    end
  end
end

