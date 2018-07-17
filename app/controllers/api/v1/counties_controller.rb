module Api
  module V1
    class CountiesController < ApplicationController
      def index
        render json: County.render
      end
    end
  end
end