class Precinct < ApplicationRecord
  belongs_to :county
  has_many :results
  has_many :candidates, through: :results
end
