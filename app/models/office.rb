class Office < ApplicationRecord
  has_many :candidates
  has_many :states, through: :candidates
  has_many :counties, through: :candidates
end
