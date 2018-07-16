class State < ApplicationRecord
  has_many :counties
  has_many :precincts, through: :counties
  has_many :results, through: :precincts
end
