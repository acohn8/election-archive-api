require 'httparty'

class State < ApplicationRecord
  has_many :counties
  has_many :precincts, through: :counties
  has_many :results
  has_many :candidates, through: :results
  has_many :offices, through: :results
  has_many :districts, through: :results

  def self.render
    State.all.map do |state|
      major_candidate_results = state.candidates.group('candidates.normalized_name').limit(5).order('sum_total DESC').sum(:total)
      major_candidate_totals = major_candidate_results.values.inject(0) { |sum, n| sum + n }
      major_candidate_results['other'] = state.results.sum(:total) - major_candidate_totals
      { name: state.name,
        fips: state.fips,
        results:  [major_candidate_results] }
      end
    end

    def render_state_results(office)
      candidate_results = Result.where(state_id: id, office_id: office.id).group('candidate_id').sum(:total).to_h
      top_three = candidate_results.sort{|a,b| a[1]<=>b[1]}.reverse[0..2].to_h
      total_votes = candidate_results.values.inject(&:+)
      other_votes = total_votes - top_three.values.inject(&:+)
      candidates = Candidate.find(top_three.keys).to_a
      state_results = {}
      state_results[:id] ||= id
      state_results[:results] ||= top_three
      state_results[:results] ||= 'other'
      state_results[:results][:other] ||= other_votes
      state_results
    end

    def render_state_county_results(office)
      formatted_hash = []
      statewide_total = Hash.new(0)
      candidate_results = Result.where(state_id: id, office_id: office.id).group(['county_id', 'candidate_id']).sum(:total).reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
      candidate_results.keys.each do |county_id|
        candidate_results[county_id].each { |k, v| statewide_total[k] += v}
      end
      top_three = statewide_total.sort{|a,b| a[1]<=>b[1]}.reverse[0..2].to_h
      state_counties = counties.to_a
      candidate_results.keys.each do |county_id|
        county_results = candidate_results[county_id].select { |k, v| top_three.keys.include?(k) }
        other_county_results = candidate_results[county_id].select { |k, v| !top_three.keys.include?(k) }.values.inject(&:+)
        county_results[:other] ||= other_county_results
        formatted_hash << {id: county_id, fips: state_counties.find { |c| c.id == county_id}.fips.to_s, results: county_results }
      end
      { results: formatted_hash }
    end

    def render_state_precint_results(office)
      formatted_hash = []
      statewide_total = Hash.new(0)
      candidate_results = Result.where(state_id: id, office_id: office.id).group(['precinct_id', 'candidate_id']).sum(:total).reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
      candidate_results.keys.each do |precinct_id|
        candidate_results[precinct_id].each { |k, v| statewide_total[k] += v}
      end
      top_three = statewide_total.sort{|a,b| a[1]<=>b[1]}.reverse[0..2].to_h
      state_precincts = precincts.to_a
      candidate_results.keys.each do |precinct_id|
        precinct_results = candidate_results[precinct_id].select { |k, v| top_three.keys.include?(k) }
        other_precinct_results = candidate_results[precinct_id].select { |k, v| !top_three.keys.include?(k) }.values.inject(&:+)
        precinct_results[:other] ||= other_precinct_results
        formatted_hash << {id: precinct_id, fips: state_precincts.find { |c| c.id == precinct_id}.fips.to_s, results: precinct_results }
      end
      { results: formatted_hash }
    end

    def render_state_congressional_district_results(office)
      formatted_hash = []
      districts = office.districts.includes(:candidate).where(candidates: {office_id: office.id})
      top_three = results.includes(:candidate).where(candidates: { office_id: office.id }).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
      candidate_results = results.includes(:county, :candidate).where(candidates: {office_id: office.id})
      major_results = candidate_results.where(candidate_id: top_three).order('counties.id').group(['counties.id', 'candidates.id']).sum(:total)
      other_results = candidate_results.where.not(candidate_id: top_three).order('counties.id').group('counties.id').sum(:total)
      county_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
      other_results.delete_if { |k, v| !county_results.include?(k) }
      county_results.keys.each do |county_id|
        if other_results.values.inject(0) { |sum, n| sum + n } > 0
          county_results[county_id] ||= [:other]
          county_results[county_id][:other] ||= other_results[county_id].to_i
        end
        formatted_hash <<  Hash[id: county_id, fips: counties.find { |c| c.id == county_id }.fips.to_s, results: county_results[county_id]]
      end
      { results: formatted_hash }
    end

    def candidate_images(office)
      formatted_hash = []
      top_candidates = candidates.distinct.where(candidates: { office_id: office.id }).where.not(candidates: { name: nil }).to_a
      senate_url = "https://en.wikipedia.org/w/api.php?action=query&prop=imageinfo&iiprop=url&generator=images&titles=United States Senate election in #{self.name}, 2016&format=json"
      governor_url =  "https://en.wikipedia.org/w/api.php?action=query&prop=imageinfo&iiprop=url&generator=images&titles=#{self.name} gubernatorial election, 2016&format=json"
      response = office.name == 'US Senate' ? HTTParty.get(senate_url) : HTTParty.get(governor_url)
      data = response['query']['pages']
      image_keys = data.keys
      top_candidates.each do |candidate|
        candidate_info = image_keys.find { |k| data[k]['title'].downcase.include?(candidate.normalized_name) }
        if candidate_info.nil?
          formatted_hash << { id: candidate.id, type:'candidates', attributes: { name: candidate.name, party: candidate.party, 'normalized-name': candidate.normalized_name, image: candidate.image } }
        else
          candidate_image = data[candidate_info]['imageinfo'][0]['url']
          formatted_hash << { id: candidate.id, type:'candidates', attributes: { name: candidate.name, party: candidate.party, 'normalized-name': candidate.normalized_name, image: candidate_image } }
        end
      end
      { data: formatted_hash }
    end

    def get_campaign_finance_data()
      response = HTTParty.get('https://api.propublica.org/campaign-finance/v1/2016/candidates/P80001571', headers: "X-API-Key: PROPUBLICA_API_KEY")
      puts response
      response
    end


    # export routes work, but not live
    def county_results_export
      formatted_hash = []
      top_three = results.includes(:candidate).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
      candidate_results = results.includes(:county, :candidate)
      major_results = candidate_results.where(candidate_id: top_three).order('counties.id').group(['counties.id', 'candidates.id']).sum(:total)
      other_results = candidate_results.where.not(candidate_id: top_three).order('counties.id').group('counties.id').sum(:total)
      county_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
      state_counties = counties.distinct.to_a
      state_candidates = candidates.distinct.to_a
      other_results.delete_if { |k, v| !county_results.include?(k) }
      county_results.keys.each do |county_id|
        county = state_counties.find { |c| c.id == county_id }
        candidate_totals = county_results[county_id].transform_keys { |k| state_candidates.find { |c| c.id == k }.name }
        candidate_totals[:other] ||= other_results[county_id]
        result = { county: county.name, fips: county.fips }.merge(candidate_totals)
        formatted_hash << result
      end
      export = CSV.generate do |csv|
        csv << formatted_hash.first.keys
        formatted_hash.each do |county|
          csv << county.values
        end
      end
      export
    end


    def precinct_results_export
      formatted_hash = []
      top_three = results.includes(:candidate).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
      candidate_results = results.includes(:precinct, :candidate)
      major_results = candidate_results.where(candidate_id: top_three).order('precincts.id').group(['precincts.id', 'candidates.id']).sum(:total)
      other_results = candidate_results.where.not(candidate_id: top_three).order('precincts.id').group('precincts.id').sum(:total)
      precinct_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
      state_counties = counties.distinct.to_a
      state_candidates = candidates.distinct.to_a
      state_precincts = precincts.distinct.to_a
      other_results.delete_if { |k, v| !precinct_results.include?(k) }
      precinct_results.keys.each do |precinct_id|
        precinct = state_precincts.find { |p| p.id == precinct_id }
        county = state_counties.find { |c| c.id == precinct.county_id }
        candidate_totals = precinct_results[precinct_id].transform_keys { |k| state_candidates.find { |c| c.id == k }.name }
        candidate_totals[:other] ||= other_results[precinct_id]
        result = { precinct: precinct.name, precinct_county: county.name, county_fips: county.fips }.merge(candidate_totals)
        formatted_hash << result
      end

      export = CSV.generate do |csv|
        csv << formatted_hash.first.keys
        formatted_hash.each do |county|
          csv << county.values
        end
      end
      export
    end
  end
