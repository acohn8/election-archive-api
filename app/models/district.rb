class District < ApplicationRecord
  has_many :offices
  has_many :candidates
  has_many :offices, through: :candidates
  has_many :states, through: :offices
end
