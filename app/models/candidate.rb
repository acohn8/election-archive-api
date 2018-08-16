
class Candidate < ApplicationRecord
  has_many :results
  has_many :states, through: :results
  has_many :counties, through: :results
  has_many :precincts, through: :results
  belongs_to :office
end
