class Precinct < ApplicationRecord
  belongs_to :county
  has_many :results
end
