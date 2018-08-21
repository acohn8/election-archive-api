class Result < ApplicationRecord
  belongs_to :precinct
  belongs_to :state
  belongs_to :county
  belongs_to :candidate
  belongs_to :office
  belongs_to :district
end
