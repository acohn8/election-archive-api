class Precinct < ApplicationRecord
  belongs_to :county
  has_many :results
  has_many :candidates, through: :results
  has_many :offices, through: :candidates
end
