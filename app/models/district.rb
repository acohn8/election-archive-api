class District < ApplicationRecord
  has_many :results
  has_many :candidates
  has_many :offices, through: :candidates
  # has_many :offices, -> { distinct }, through: :results
  # has_many :candidates, -> { distinct }, through: :results
  has_many :states, -> { distinct }, through: :results
  has_many :counties, -> { distinct }, through: :results
  has_many :precincts, -> { distinct }, through: :results
end
