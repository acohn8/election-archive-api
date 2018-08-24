
class Candidate < ApplicationRecord
  has_many :results
  has_many :states, through: :results
  has_many :counties, through: :results
  has_many :precincts, through: :results
  has_many :offices, through: :results
  has_many :districts, through: :results

  def get_campaign_finance_data
    response = HTTParty.get("https://api.propublica.org/campaign-finance/v1/2016/candidates/#{fec_id}.json", { headers: { "X-API-Key": "WyNN5Tk4AxHWexaSE1K6YIMjlHiZQnHmQl4cyCtu" }})
  end
end
