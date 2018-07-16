class State < ApplicationRecord
  has_many :counties
  has_many :precincts, through: :counties
  has_many :results, through: :precincts

  def total
   results = self.results.map { |r| r.total }
   results.inject(0) { |sum, n| sum + n }
  end

end
