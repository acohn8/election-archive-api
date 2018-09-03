
class Candidate < ApplicationRecord
  has_many :results
  has_many :states, -> { distinct }, through: :results
  has_many :counties, -> { distinct }, through: :results
  has_many :precincts, -> { distinct }, through: :results
  # has_many :offices, -> { distinct }, through: :results
  # has_many :districts, -> { distinct }, through: :results
  belongs_to :office
  belongs_to :district

  def get_campaign_finance_data
    if !fec_id.nil? && fec_id.split(' ').length == 1
      response = HTTParty.get("https://api.propublica.org/campaign-finance/v1/2016/candidates/#{fec_id}.json", { headers: { "X-API-Key": "WyNN5Tk4AxHWexaSE1K6YIMjlHiZQnHmQl4cyCtu" }})
      if response['status'] != '404'
        data = response['results'][0]
        data[:candidate_id] = id
        return data
      end
    elsif !fec_id.nil? && fec_id.split(' ').length > 1
      fec_ids = fec_id.split(' ')
      candidate_office = office.name.split('US ').last
      matched_id = fec_ids.find { |i| i[0].downcase === candidate_office[0].downcase }.gsub(/\W$/, "")
      response = HTTParty.get("https://api.propublica.org/campaign-finance/v1/2016/candidates/#{matched_id}.json", { headers: { "X-API-Key": "WyNN5Tk4AxHWexaSE1K6YIMjlHiZQnHmQl4cyCtu" }})
      if response['status'] != '404'
        data = response['results'][0]
        data[:candidate_id] = id
        return data
      end
    end
  end
end
