module Api
  module V1
    class WeathersController < ApplicationController
      def show
        @coords = params['link'].split(',')
        url = "https://api.darksky.net/forecast/1114b767335760c2ae618d019fe72dd0/#{@coords[0]},#{@coords[1]}"
        weather = HTTParty.get(url)
        render json: weather
      end
    end
  end
end
