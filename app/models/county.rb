class County < ApplicationRecord
  belongs_to :state
  has_many :results
  has_many :candidates, through: :results
  has_many :precincts

  def self.render
    County.all.map do |county|
      major_candidate_results = county.candidates.group('candidates.normalized_name').limit(5).order('sum_total DESC').sum(:total)
      major_candidate_totals = major_candidate_results.values.inject(0) { |sum, n| sum + n }
      major_candidate_results['other'] = county.results.sum(:total) - major_candidate_totals
      { name: county.name,
        fips: county.fips,
        results:  [major_candidate_results]
      }
    end
  end

  def total
    self.results.sum(:total)
  end
end
