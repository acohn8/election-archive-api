class County < ApplicationRecord
  belongs_to :state
  has_many :results
  has_many :candidates, through: :results
  has_many :precincts

  def render_county_precint_results
    formatted_hash = []
    top_three = results.includes(:candidate).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
    candidate_results = results.includes(:precinct, :candidate)
    major_results = candidate_results.where(candidate_id: top_three).order('precincts.id').group(['precincts.id', 'candidates.id']).sum(:total)
    other_results = candidate_results.where.not(candidate_id: top_three).order('precincts.id').group('precincts.id').sum(:total)
    precinct_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
    other_results.each do |precinct, total|
      precinct_results[precinct] ||= [:other]
      precinct_results[precinct][:other] ||= total
      formatted_hash <<  Hash[id: id, results: precinct_results[precinct]]
    end
     { results: formatted_hash }
  end
end
