class State < ApplicationRecord
  has_many :counties
  has_many :precincts, through: :counties
end
