
class Candidate < ApplicationRecord
  has_many :results
  has_many :states, -> { distinct }, through: :results
  has_many :counties, -> { distinct }, through: :results
  has_many :precincts, -> { distinct }, through: :results
  # has_many :offices, -> { distinct }, through: :results
  # has_many :districts, -> { distinct }, through: :results
  belongs_to :office
  belongs_to :district

  def self.get_campaign_finance_data(candidates)
    finance_data = {}
    candidates.each do |candidate|
      if !candidate[:fec_id].nil? && candidate.fec_id.split(' ').length == 1
        response = HTTParty.get("https://api.propublica.org/campaign-finance/v1/2016/candidates/#{candidate.fec_id}.json", { headers: { "X-API-Key": "WyNN5Tk4AxHWexaSE1K6YIMjlHiZQnHmQl4cyCtu" }})
        finance_data[candidate.id] ||= response['results'][0] unless response['status'] == '404'
      elsif !candidate[:fec_id].nil? && candidate.fec_id.split(' ').length > 1
        fec_ids = candidate.fec_id.split(' ')
        candidate_office = candidate.office.name.split('US ').last
        matched_id = fec_ids.find { |i| i[0].downcase === candidate_office[0].downcase }.gsub(/\W$/, "")
        response = HTTParty.get("https://api.propublica.org/campaign-finance/v1/2016/candidates/#{matched_id}.json", { headers: { "X-API-Key": "WyNN5Tk4AxHWexaSE1K6YIMjlHiZQnHmQl4cyCtu" }})
        finance_data[candidate.id] ||= response['results'][0] unless response['status'] == '404'
      end
    end
    finance_data
  end
end
