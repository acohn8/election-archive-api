class County < ApplicationRecord
  belongs_to :state
  has_many :results
  has_many :candidates, through: :results
  has_many :precincts

  def render_county_precint_results(office)
    formatted_hash = []
    county_with_precincts = County.includes(:precincts).where(id: id).distinct
    top_three = results.includes(:candidate).where(candidates: { office_id: office.id }).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
    candidate_results = results.includes(:precinct, :candidate).where(candidates: { office_id: office.id })
    major_results = candidate_results.where(candidate_id: top_three).order('precincts.id').group(['precincts.id', 'candidates.id']).sum(:total)
    other_results = candidate_results.where.not(candidate_id: top_three).order('precincts.id').group('precincts.id').sum(:total)
    precinct_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
    other_results.delete_if { |k, v| !precinct_results.include?(k) }
    precinct_results.keys.each do |precinct_id|
      precinct_results[precinct_id] ||= [:other]
      precinct_results[precinct_id][:other] ||= other_results[precinct_id].to_i
      formatted_hash <<  Hash[name: county_with_precincts.first.precincts.find { |p| p.id == precinct_id }.name, results: precinct_results[precinct_id]]
    end
    { results: formatted_hash }
  end
end
