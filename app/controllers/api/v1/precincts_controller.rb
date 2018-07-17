module Api
  module V1
    class PrecinctsController < ApplicationController
      def index
        render json: Precinct.render
      end
    end
  end
end