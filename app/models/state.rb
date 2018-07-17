class State < ApplicationRecord
  has_many :counties
  has_many :precincts, through: :counties
  has_many :results, through: :counties
  has_many :candidates, through: :counties


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
    major_candidates = candidates.group('candidates.id').limit(5).order('sum_total DESC').sum(:total).keys
    to_list = Candidate.find(major_candidates)
    { name: name,
      fips: fips,
      counties:
      counties.map do |county|
        # major_candidate_results = county.candidates.group('candidates.normalized_name').limit(5).order('sum_total DESC').sum(:total)
        # major_candidate_totals = major_candidate_results.values.inject(0) { |sum, n| sum + n }
        # major_candidate_results['other'] = county.results.sum(:total) - major_candidate_totals
        {
          county_name: county.name,
          county_fips: county.fips,
          results:  to_list.map do |candidate|
            {
            name: candidate.name,
            party: candidate.party,
            total: candidate.results.where(county: county).sum(:total)
            }
          end
        }
      end
    }
  end

  def render_precincts
    { name: name,
      fips: fips,
      precincts:
      precincts.map do |precinct|
        major_candidate_results = precinct.candidates.group('candidates.normalized_name').limit(5).order('sum_total DESC').sum(:total)
        major_candidate_totals = major_candidate_results.values.inject(0) { |sum, n| sum + n }
        major_candidate_results['other'] = precinct.results.sum(:total) - major_candidate_totals
        {
          precinct_name: precinct.name,
          results:  [major_candidate_results]
        }
      end }
    end

  def render_show
    major_candidate_results = self.candidates.group('candidates.normalized_name').limit(5).order('sum_total DESC').sum(:total)
    major_candidate_totals = major_candidate_results.values.inject(0) { |sum, n| sum + n }
    major_candidate_results['other'] = self.results.sum(:total) - major_candidate_totals
    { name: name,
      fips: fips,
      results:  [major_candidate_results] }
  end
end
