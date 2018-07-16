class Result < ApplicationRecord
  belongs_to :precinct
  belongs_to :candidate
end
