class Office < ApplicationRecord
  has_many :results
  has_many :candidates
  has_many :districts, through: :candidates
  # has_many :districts, -> { distinct }, through: :results
  # has_many :candidates, -> { distinct }, through: :results
  has_many :states, -> { distinct }, through: :results
  has_many :counties, -> { distinct }, through: :results
  has_many :precincts, -> { distinct }, through: :results
end