class Precinct < ApplicationRecord
  belongs_to :county
  has_many :results

  def total
    self.results.sum(:total)
   end

   def candidate_total(id)
    self.results.where(candidate_id: id).sum(:total)
   end

   def dem_total
    self.results.where(candidate_id: Candidate.major_dem.id).sum(:total)
   end

   def gop_total
    #check this
    self.results.where(candidate_id: Candidate.major_gop.id).sum(:total)
   end

   def gop_total
   end
end
