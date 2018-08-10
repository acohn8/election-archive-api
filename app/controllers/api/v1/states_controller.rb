module Api
  module V1
    class StatesController < ApplicationController
      def index
        render json: State.all.order('name')
      end
    end
  end
end

