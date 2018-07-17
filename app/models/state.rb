class State < ApplicationRecord
  has_many :counties
  has_many :precincts, through: :counties
  has_many :results, through: :precincts
  has_many :candidates, through: :results

  def self.render
    State.all.map do |state|
      { name: state.name,
        results:  state.results.joins(:candidate).where(results: { county_id: state.id }).group('candidates.party').sum(:total)
        }
    end
  end

  # def total
  #  self.results.sum(:total)
  # end

  # def dem_total
  #   results.joins(:candidate).where(results: { state_id: id }, candidates: { fec_id: 'P00003392' }).sum(:total)
  # end

  # def gop_total
  #   results.joins(:candidate).where(results: { state_id: id }, candidates: { fec_id: 'P80001571' }).sum(:total)
  # end

  # def lib_total
  #   results.joins(:candidate).where(results: { state_id: id }, candidates: { fec_id: 'P60012234' }).sum(:total)
  # end

  # def green_total
  #   results.joins(:candidate).where(results: { state_id: id }, candidates: { fec_id: 'P20003984' }).sum(:total)
  # end

  # def other_total
  #   self.total - (self.dem_total + self.gop_total + self.lib_total + self.green_total)
  # end
end
