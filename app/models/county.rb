class County < ApplicationRecord
  belongs_to :state
  has_many :precincts
  has_many :results, through: :precincts
end
