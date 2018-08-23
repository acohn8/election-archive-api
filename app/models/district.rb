class District < ApplicationRecord
  has_many :results
  has_many :offices, -> { distinct }, through: :results
  has_many :candidates, through: :results
  has_many :states, through: :results
  has_many :counties, through: :results
  has_many :precincts, through: :results
end
