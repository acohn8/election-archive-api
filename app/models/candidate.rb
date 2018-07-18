class Candidate < ApplicationRecord
  has_many :results
  has_many :states, through: :results
  has_many :counties, through: :results
  has_many :precincts, through: :results

  def details(geography)
    {
      name: self.name,
      normalized_name: self.normalized_name,
      fec_id: self.fec_id,
      party: self.party,
      results: geography.results.where(candidate_id: self.id).sum(:total)
    }
  end
end
