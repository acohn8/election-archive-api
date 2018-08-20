class Office < ApplicationRecord
  has_many :candidates
  has_many :state_offices
  has_many :district_offices
  has_many :districts, through: :candidates
  has_many :states, through: :state_offices
  has_many :counties, through: :candidates
end
