class State < ApplicationRecord
  has_many :counties
  has_many :results
  has_many :candidates, through: :results
  has_many :precincts, through: :counties

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

  def render_state_results
    top_three = results.includes(:candidate).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
    candidate_results = results.includes(:candidate)
    major_results = candidate_results.where(candidate_id: top_three).group('candidates.id').sum(:total)
    other_results = candidate_results.where.not(candidate_id: top_three).group('candidates.id').sum(:total)
    other_results.delete_if { |k, v| !major_results.include?(k) }
    major_results[:other] ||= other_results.values.inject(0) { |sum, n| sum + n}
     { id: id, results: major_results }
  end

  def render_state_county_results
    formatted_hash = []
    top_three = results.includes(:candidate).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
    candidate_results = results.includes(:county, :candidate)
    major_results = candidate_results.where(candidate_id: top_three).order('counties.id').group(['counties.id', 'candidates.id']).sum(:total)
    other_results = candidate_results.where.not(candidate_id: top_three).order('counties.id').group('counties.id').sum(:total)
    county_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
    other_results.delete_if { |k, v| !county_results.include?(k) }
    other_results.each do |county, total|
      county_results[county] ||= [:other]
      county_results[county][:other] ||= total
      formatted_hash <<  Hash[id: county, results: county_results[county]]
    end
     { results: formatted_hash }
  end

  def render_state_precint_results
    formatted_hash = []
    top_three = results.includes(:candidate).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
    candidate_results = results.includes(:precinct, :candidate)
    major_results = candidate_results.where(candidate_id: top_three).order('precincts.id').group(['precincts.id', 'candidates.id']).sum(:total)
    other_results = candidate_results.where.not(candidate_id: top_three).order('precincts.id').group('precincts.id').sum(:total)
    precinct_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
    other_results.delete_if { |k, v| !precinct_results.include?(k) }
    other_results.each do |precinct, total|
      precinct_results[precinct] ||= [:other]
      precinct_results[precinct][:other] ||= total
      formatted_hash <<  Hash[id: precinct, county_id: candidate_results.find { |p| p.id == precinct }.county_id, results: precinct_results[precinct]]
    end
     { results: formatted_hash }
  end

  def render_show
    { name: name,
      fips: fips,
      results:  candidates.distinct.map do |candidate|
        {
          name: candidate.name,
          normalized_name: candidate.normalized_name,
          fec_id: candidate.fec_id,
          party: candidate.party,
          results: candidate.results.sum(:total)
        }
     end
  }
  end
end
