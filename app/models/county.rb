class County < ApplicationRecord
  belongs_to :state
  has_many :precincts
  has_many :results, through: :precincts

  def total
    results = self.results.map { |r| r.total }
    results.inject(0) { |sum, n| sum + n }
   end
end
