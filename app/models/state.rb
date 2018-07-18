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
    counties_with_candidates = counties.includes(:results).includes(:candidates)
    { name: name,
      fips: fips,
      counties: counties_with_candidates.to_a.map do |county|
        results = county.candidates.group('candidates.id').sum(:total)
        {
          county_name: county.name,
          county_fips: county.fips,
          candidates: county.candidates.uniq.map do |candidate|
            {
            name: candidate.name,
            normalized_name: candidate.normalized_name,
            fec_id: candidate.fec_id,
            party: candidate.party,
            results: results[candidate.id]
            }
          end
      }
    end
  }
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
            name: candidate.name,
            normalized_name: candidate.normalized_name,
            party: candidate.party,
            results: results[candidate.id]
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
