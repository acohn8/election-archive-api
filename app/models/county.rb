class County < ApplicationRecord
  belongs_to :state
  has_many :precincts
  has_many :results
  has_many :candidates, -> { distinct }, through: :results
  has_many :offices, -> { distinct }, through: :results
  has_many :districts, -> { distinct }, through: :results

  def render_county_precint_results(office)
    formatted_hash = []
    statewide_total = Hash.new(0)
    candidate_results = Result.where(state_id: state_id, office_id: office.id, county_id: id).group(['precinct_id', 'candidate_id']).sum(:total).reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
    candidate_results.keys.each do |precinct_id|
      candidate_results[precinct_id].each { |k, v| statewide_total[k] += v}
    end
    county_precincts = precincts
    top_three = statewide_total.sort{|a,b| a[1]<=>b[1]}.reverse[0..2].to_h
    candidate_results.keys.each do |precinct_id|
      precinct_results = candidate_results[precinct_id].select { |k, v| top_three.keys.include?(k) }
      other_precinct_results = candidate_results[precinct_id].select { |k, v| !top_three.keys.include?(k) }.values.inject(&:+)
      other_precinct_results = 0 if other_precinct_results.nil?
      precinct_results[:other] ||= other_precinct_results
      formatted_hash << { id: precinct_id, name: county_precincts.find { |p| p.id == precinct_id }.name, results: precinct_results }
    end
    { results: formatted_hash }
  end

  def county_info
    details_url = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=#{name}, #{state.name}&format=json"
    details = HTTParty.get(details_url)
    page_key = details['query']['pages'].keys[0]
    county_summary = details['query']['pages'][page_key]['extract']
    images = get_county_images
    to_render = {}
    to_render[:id] = id
    to_render[:name] = name
    !county_summary.nil? ? to_render[:details] = county_summary : to_render[:details] = nil
    !images.nil? ? to_render[:images] = images : to_render[:images] = []
    to_render
  end

  def get_county_images
    images_url = "https://en.wikipedia.org/w/api.php?action=query&prop=imageinfo&iiprop=url&generator=images&titles=#{name}, #{state.name}&format=json"
    images = HTTParty.get(images_url)
    image_keys = images['query']['pages'].keys
    image_keys.map do |key|
      image_info = {}
      image_info[:url] = images['query']['pages'][key]['imageinfo'][0]['url']
      image_info[:title] = images['query']['pages'][key]['title']
      image_info
    end
  end
end