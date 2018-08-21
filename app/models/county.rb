class County < ApplicationRecord
  belongs_to :state
  has_many :precincts
  has_many :results
  has_many :candidates, through: :results
  has_many :offices, through: :results
  has_many :districts, through: :results

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
      precinct_results[:other] ||= other_precinct_results
      formatted_hash << { id: precinct_id, name: county_precincts.find { |p| p.id == precinct_id }.name, results: precinct_results }
    end
    { results: formatted_hash }
  end
end
