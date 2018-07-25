class County < ApplicationRecord
  belongs_to :state
  has_many :results
  has_many :candidates, through: :results
  has_many :precincts

end
