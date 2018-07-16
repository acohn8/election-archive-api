class Candidate < ApplicationRecord
  has_many :results

  def statewide_total
    results = self.results.map {|r| r.total }
    results.inject(0) { |sum, n| sum + n}
  end
end
