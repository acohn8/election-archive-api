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
    major_candidates = candidates.group('candidates.id').limit(5).order('sum_total DESC').sum(:total)
    candidates = Candidate.find(major_candidates.keys).to_a.map(&:serializable_hash).sort_by { |h| h['id'] }
    { name: name,
      fips: fips,
      counties: counties.map do |county|
        results = County.joins(:candidates).where(candidates: {id: major_candidates.keys}, counties: {id: county.id}).group('candidates.id').sum(:total).values
        candidate_results = candidates.zip(results)
        {
          county_name: county.name,
          county_fips: county.fips,
          results: candidate_results.map do |candidate|
            {
            name: candidate[0]['name'],
            normalized_name: candidate[0]['normalized_name'],
            fec_id: candidate[0]['fec_id'],
            party: candidate[0]['party'],
            total: candidate.last
          }
        end
        }
      end
      }
    end

  def render_precincts
    major_candidates = candidates.group('candidates.id').limit(5).order('sum_total DESC').sum(:total)
    candidates = Candidate.find(major_candidates.keys).to_a.map(&:serializable_hash).sort_by { |h| h['id'] }
    { name: name,
      fips: fips,
      precincts: precincts.map do |precinct|
        results = Precinct.joins(:candidates).where(candidates: {id: major_candidates.keys}, precincts: {id: precinct.id}).group('candidates.id').sum(:total).values
        candidate_results = candidates.zip(results)
        {
          precinct_name: precinct.name,
          results: candidate_results.map do |candidate|
            {
            name: candidate[0]['name'],
            normalized_name: candidate[0]['normalized_name'],
            fec_id: candidate[0]['fec_id'],
            party: candidate[0]['party'],
            total: candidate.last
          }
        end
        }
      end
      }
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
