class Candidate < ApplicationRecord
  has_many :results

  def self.major_dem
    democrats = Candidate.all.where(party: 'democratic')
    democrats.sort_by(&:statewide_total).last
  end

  def self.major_gop
    republicans = Candidate.all.where(party: 'republican')
    republicans.sort_by(&:statewide_total).last
  end

  def self.dem_results
    self.major_dem.statewide_total
  end

  def self.gop_results
    self.major_gop.statewide_total
  end

  def self.winner
    Candidate.all.sort_by(&:statewide_total).last
  end

  def statewide_total
    self.results.sum(:total)
  end
end
