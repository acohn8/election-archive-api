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
    county_results.keys.each do |county_id|
      county_results[county_id] ||= [:other]
      county_results[county_id][:other] ||= other_results[county_id].to_i
      formatted_hash <<  Hash[id: county_id, results: county_results[county_id]]
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
    precinct_results.keys.each do |precinct_id|
      precinct_results[precinct_id] ||= [:other]
      precinct_results[precinct_id][:other] ||= other_results[precinct_id].to_i
      formatted_hash << Hash[id: precinct_id, county_id: candidate_results.find { |p| p.precinct_id == precinct_id }.county_id, results: precinct_results[precinct_id]]
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
