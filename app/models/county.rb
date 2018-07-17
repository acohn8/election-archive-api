class County < ApplicationRecord
  belongs_to :state
  has_many :precincts
  has_many :results, through: :precincts

  def total
    self.results.sum(:total)
   end

  def dem_total
    self.results.joins(:candidate).where(candidates: { party: 'democratic' }).sum(:total)
  end

  def gop_total
    self.results.joins(:candidate).where(candidates: { party: 'republican' }).sum(:total)
  end
end
