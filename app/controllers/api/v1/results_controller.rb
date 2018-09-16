module Api
  module V1
    class ResultsController < ApplicationController

      def office_candidates
        @state = State.find(params['state_id'])
        @office = Office.find(params['office_id'])
        if @office.name == 'US President' || @office.name == 'US House'
          candidates = @state.results.where(office_id: @office.id).pluck(:candidate_id).uniq
          render json: Candidate.find(candidates)
        else
          render json: @state.candidate_images(@office)
        end
      end

      def state_results
        @state = State.find(params['state_id'])
        @office = Office.find(params['office_id'])
        render json: @state.render_state_results(@office)
      end

      def district_results
        @state = State.find(params['state_id'])
        @office = Office.find(params['office_id'])
        @district = District.find_by(name: params[:district_id].upcase)
          render json: @state.render_state_results(@office, @district)
      end

        def county_results
          @state = State.find(params['state_id'])
          @office = Office.find(params['office_id'])
          render json: @state.render_state_county_results(@office)
        end

        def congressional_district_results
          @state = State.find(params['state_id'])
          @office = Office.find(params['office_id'])
          @district = District.find_by(name: params[:district_id].upcase)
          render json: @state.render_state_county_results(@office, @district)
        end

        def precinct_results
          @county = County.find(params['county_id'])
          @office = Office.find(params['office_id'])
          render json: @county.render_county_precinct_results(@office)
        end

        def render_county_district_precint_results
          @state = State.find(params['state_id'])
          @office = Office.find(params['office_id'])
          @district = District.find_by(name: params[:district_id].upcase)
          @county = County.find(params['county_id'])
          render json: @county.render_district_precinct_results(@office, @district)
        end
      end
    end
  end
