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
      return office.results.where(results: { state_id: id }).group(:candidate_id).sum(:total)
    else
      return office.results.where(results: { state_id: id, district_id: district.id }).group(:candidate_id).sum(:total)
    end
  end

  def get_candidate_info(candidates)
    candidate_info = []
    candidates.each do |candidate|
      candidate_attributes = candidate.serializable_hash()
      candidate_attributes[:finance_data] = candidate.get_campaign_finance_data
      candidate_info << candidate_attributes
    end
    other = { id: 'other',  name: 'Other', party: 'other'}
    candidate_info << other
  end

  def render_state_results(office, district = nil)
    candidate_results = filter_state_results(office, district)
    top_two = candidate_results.sort{|a,b| a[1]<=>b[1]}.reverse[0..1].to_h
    total_votes = candidate_results.values.inject(&:+)
    other_votes = total_votes - top_two.values.inject(&:+)
    office_candidates = Candidate.find(top_two.keys).to_a
    candidate_info = get_candidate_info(office_candidates)
    fetch_url = format_fetch_url(office.name)
    details_url = get_overview_link(office.name)
    overview = get_race_overview(fetch_url)
    state_results = {}
    state_results[:office_name] ||= district.nil? ? office.name : district.name
    state_results[:id] ||= id
    state_results[:candidates] ||= candidate_info
    state_results[:office] ||= office
    state_results[:results] ||= top_two
    state_results[:results][0] ||= other_votes
    state_results = state_results.as_json
    state_results['office']['overview'] ||= !overview.nil? ? overview : nil
    state_results['office']['overview_link'] ||= !details_url.nil? ? details_url : nil
    state_results
  end

  def format_fetch_url(office)
    formatted_office = office.split(' ').map(&:downcase).join('_').to_sym
    links = {
      us_president: "United_States_presidential_election_in_#{name},_2016",
      us_senate: "United_States_Senate_election_in_#{name},_2016",
      us_house: "United_States_House_of_Representatives_elections_in_#{name},_2016",
      governor: "#{name}_gubernatorial_election,_2016"
    }
    "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=#{links[formatted_office]}&format=json"
  end

  def get_race_overview(url)
    details = HTTParty.get(url)
    page_key = details['query']['pages'].keys[0]
    race_summary = details['query']['pages'][page_key]['extract']
    race_summary
  end

  def get_overview_link(office)
    formatted_office = office.split(' ').map(&:downcase).join('_').to_sym
    links = {
      us_president: "United_States_presidential_election_in_#{name},_2016",
      us_senate: "United_States_Senate_election_in_#{name},_2016",
      us_house: "United_States_House_of_Representatives_elections_in_#{name},_2016",
      governor: "#{name}_gubernatorial_election,_2016"
    }
    "https://en.wikipedia.org/wiki/#{links[formatted_office]}"
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
    top_two = statewide_total.sort{|a,b| a[1]<=>b[1]}.reverse[0..1].to_h
    state_counties = counties.to_a
    candidate_results.keys.each do |county_id|
      county_results = candidate_results[county_id].select { |k, v| top_two.keys.include?(k) }
      other_county_results = candidate_results[county_id].select { |k, v| !top_two.keys.include?(k) }.values.inject(&:+)
      other_county_results = 0 if other_county_results.nil?
      county_results[:other] ||= other_county_results
      name = state_counties.find { |c| c.id == county_id}.name
      formatted_hash << {id: county_id, fips: state_counties.find { |c| c.id == county_id}.fips.to_s, name: name, results: county_results } if !name.nil?
    end
    { results: formatted_hash.sort { |a,b| a[:name] <=> b[:name] } }
  end

  def render_state_precint_results(office)
    formatted_hash = []
    statewide_total = Hash.new(0)
    candidate_results = Result.where(state_id: id, office_id: office.id).group(['precinct_id', 'candidate_id']).sum(:total).reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
    candidate_results.keys.each do |precinct_id|
      candidate_results[precinct_id].each { |k, v| statewide_total[k] += v}
    end
    top_two = statewide_total.sort{|a,b| a[1]<=>b[1]}.reverse[0..1].to_h
    state_precincts = precincts.to_a
    candidate_results.keys.each do |precinct_id|
      precinct_results = candidate_results[precinct_id].select { |k, v| top_two.keys.include?(k) }
      other_precinct_results = candidate_results[precinct_id].select { |k, v| !top_two.keys.include?(k) }.values.inject(&:+)
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


end
