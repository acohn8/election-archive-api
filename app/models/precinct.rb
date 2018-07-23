class Precinct < ApplicationRecord
  belongs_to :county
  has_many :results
  has_many :candidates, through: :results

  def self.render
    Precinct.all.map do |precinct|
      { name: precinct.name,
        results: precinct.results.joins(:candidate).where(results: { precinct_id: precinct.id }).group('candidates.party').sum(:total)
         }
    end
  end
end
