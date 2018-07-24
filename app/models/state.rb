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

  def render_counties
    formatted_hash = []
    candidate_results = results.includes(:county, :candidate)
    major_results = candidate_results.where(candidate_id: [14, 10, 16]).order('counties.id').group(['counties.id', 'candidates.id']).sum(:total)
    other_results = candidate_results.where.not(candidate_id: [14, 10, 16]).order('counties.id').group('counties.id').sum(:total)
    county_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
    other_results.each do |county, total|
      county_results[county] ||= [:other]
      county_results[county][:other] ||= total
      formatted_hash <<  Hash[id: county, results: county_results[county]]
    end
     { results: formatted_hash }
  end

  def render_precincts
    precincts_with_candidates = precincts.includes(:results).includes(:candidates)
    { name: name,
      fips: fips,
      precincts: precincts_with_candidates.to_a.map do |precinct|
        results = precinct.candidates.group('candidates.id').sum(:total)
        {
          precinct_name: precinct.name,
          candidates: precinct.candidates.uniq.map do |candidate|
            {
            name: candidate['name'],
            normalized_name: candidate['normalized_name'],
            party: candidate['party'],
            results: results['candidate']['id']
          }
          end
      }
    end
  }
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
