
class Candidate < ApplicationRecord
  has_many :results
  has_many :states, through: :results
  has_many :counties, through: :results
  has_many :precincts, through: :results
  has_many :offices, through: :results
  has_many :districts, through: :results
end
