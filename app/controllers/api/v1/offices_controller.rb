module Api
  module V1
    class OfficesController < ApplicationController
      def index
        @state = State.find(params['state_id'])
        state_offices = @state.offices.to_a
        offices_with_districts = []
        state_offices.each do |office|
          districts = Result.where(state_id: @state.id, office_id: office.id).pluck(:district_id).uniq
          offices_with_districts << { id: office.id.to_s, name: office.name, state_map: office.state_map, county_map: office.county_map, districts: District.where(id: districts) }
        end
        render json: offices_with_districts
      end

      def show
        @office = Office.find(params['office_id'])
        render json: @office
      end

      def all_offices
        render json: Office.find([309, 313, 308, 322])
      end
    end
  end
end
