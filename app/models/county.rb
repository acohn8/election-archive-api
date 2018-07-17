class County < ApplicationRecord
  belongs_to :state
  has_many :precincts
  has_many :results, through: :precincts
  has_many :candidates, through: :results

  def self.render
    County.all.map do |county|
      { name: county.name,
        results:  county.results.joins(:candidate).where(results: { county_id: county.id }).group('candidates.party').sum(:total)
      }
    end
  end

  # def total
  #   results.sum(:total)
  # end

  # def dem_total
  #   results.joins(:candidate).where(results: { county_id: id }, candidates: { fec_id: 'P00003392' }).sum(:total)
  # end

  # def gop_total
  #   results.joins(:candidate).where(results: { county_id: id }, candidates: { fec_id: 'P80001571' }).sum(:total)
  # end

  # def lib_total
  #   results.joins(:candidate).where(results: { county_id: id }, candidates: { fec_id: 'P60012234' }).sum(:total)
  # end

  # def green_total
  #   results.joins(:candidate).where(results: { county_id: id }, candidates: { fec_id: 'P20003984' }).sum(:total)
  # end

  # def other_total
  #   total - (dem_total + gop_total + lib_total + green_total)
  # end
end
