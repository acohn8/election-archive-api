class Result < ApplicationRecord
  belongs_to :precinct
  belongs_to :state
  belongs_to :county
  belongs_to :candidate

  def render_results
    formatted_hash = []
    candidate_results = results.includes(:county, :candidate)
    major_results = candidate_results.where(candidate_id: [18, 14, 10, 12, 16]).order('counties.id').group(['counties.id', 'candidates.id']).sum(:total)
    other_results = candidate_results.where.not(candidate_id: [18, 14, 10, 12, 16]).order('counties.id').group('counties.id').sum(:total)
    county_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
    other_results.each do |county, total|
      county_results[county] ||= [:other]
      county_results[county][:other] ||= total
      formatted_hash << Hash[name: county, results: [county_results[county]]]
    end
     { county_results: formatted_hash }
  end
end
