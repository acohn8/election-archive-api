class Candidate < ApplicationRecord
  has_many :results
  has_many :states
end
