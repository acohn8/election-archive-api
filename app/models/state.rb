require 'httparty'

class State < ApplicationRecord
  has_many :counties
  has_many :precincts, through: :counties
  has_many :results
  has_many :candidates, -> { distinct }, through: :results
  has_many :offices, -> { distinct }, through: :results
  has_many :districts, -> { distinct }, through: :results

  def filter_state_results(office, district)
    if district == nil
      return Result.where(state_id: id, office_id: office.id).group(:candidate_id).sum(:total)
    else
      return Result.where(state_id: id, office_id: office.id, district_id: district.id).group(:candidate_id).sum(:total)
    end
  end

    def render_state_results(office, district = nil)
      candidate_results = filter_state_results(office, district)
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

    def filter_county_results(office, district)
      if district == nil
        return Result.where(state_id: id, office_id: office.id).group([:county_id, :candidate_id]).sum(:total).reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
      else
        Result.where(state_id: id, office_id: office.id, district_id: district.id).group([:county_id, :candidate_id]).sum(:total).reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
      end
    end

    def render_state_county_results(office, district = nil)
      formatted_hash = []
      statewide_total = Hash.new(0)
      candidate_results = filter_county_results(office, district)
      candidate_results.keys.each do |county_id|
        candidate_results[county_id].each { |k, v| statewide_total[k] += v}
      end
      top_three = statewide_total.sort{|a,b| a[1]<=>b[1]}.reverse[0..2].to_h
      state_counties = counties.to_a
      candidate_results.keys.each do |county_id|
        county_results = candidate_results[county_id].select { |k, v| top_three.keys.include?(k) }
        other_county_results = candidate_results[county_id].select { |k, v| !top_three.keys.include?(k) }.values.inject(&:+)
        other_county_results = 0 if other_county_results.nil?
        county_results[:other] ||= other_county_results
        formatted_hash << {id: county_id, fips: state_counties.find { |c| c.id == county_id}.fips.to_s, name: state_counties.find { |c| c.id == county_id}.name, results: county_results }
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
        other_precinct_results = 0 if other_precinct_results.nil?
        formatted_hash << { id: precinct_id, fips: state_precincts.find { |c| c.id == precinct_id}.fips.to_s, results: precinct_results }
      end
      { results: formatted_hash }
    end

    def candidate_images(office)
      formatted_hash = []
      candidate_ids = Result.where(office_id: office.id, state_id: id).pluck(:candidate_id).uniq
      top_candidates = Candidate.where(id: candidate_ids).where.not(name: nil).to_a
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
  end
