class State < ApplicationRecord
  has_many :counties
  has_many :precincts, through: :counties
  has_many :results, through: :precincts
  has_many :candidates, through: :results

  def self.render
    State.all.map do |state|
      { name: state.name,
        fips: state.fips,
        results:  state.results.joins(:candidate).where(results: { state_id: state.id }).group('candidates.party').sum(:total) }
    end
  end

  def render_counties
    { name: name,
      fips: fips,
      counties:
      counties.map do |county|
        {
          county_name: county.name,
          county_fips: county.fips,
          county_results:  county.results.includes(:candidate).where(results: { county_id: county.id }).group('candidates.party').sum(:total)
        }
      end }
  end

    def render_precincts
      { name: name,
        fips: fips,
        results:
        precincts.map do |precinct|
          {
            precinct_name: precinct.name,
            precinct_results:  precinct.results.includes(:candidate).where(results: { precinct_id: precinct.id }).group('candidates.party').sum(:total)
          }
        end }
      end

  def render_show
    { name: name,
      fips: fips,
      results:  results.joins(:candidate).where(results: { county_id: id }).group('candidates.party').sum(:total) }
  end
end
