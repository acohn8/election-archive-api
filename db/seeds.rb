require 'csv'


#exceptions:
#AK boroughs
#AL Party-line voting appears in the data as office values of Straight Party and candidate values of, for example, Alabama Republican Party. To calculate vote totals, sum the votes candidates' received on their own lines and from party-line voting.
#ME broken
#reload nh

#candidate fix

#NM

#fixes: normalize candidates
#SD county has new FIPS and name
#RI has weird non-geospecific totals to remove
#HI Kalawao county does not admin elections, but needs a dummy line in the db with a fips of 15005 and a dummy result


def seed_state
  states = ['nd']
  states.each do |state|
    data = CSV.open("/Users/adamcohn/Documents/development/projects/election_data/precinct-returns/source/2016-#{state}-precinct.csv", headers: :first_row, encoding: 'iso-8859-1:utf-8').map(&:to_h)
    filtered_data = data.select{ |row| row['office'] == 'Governor and Lt. Governor'}
    filtered_data.each do |row|
      puts "#{row['candidate']}, #{row['county_name']}"
      state = State.find_or_create_by(name: row['state'], short_name: row['state_postal'], fips: row['state_fips'])
      office = Office.find_or_create_by(name: 'Governor', district: 'statewide')
      county = County.find_or_create_by(name: row['county_name'], fips: row['county_fips'], latitude: row['county_lat'], longitude: row['county_long'], state: state)
      precinct = Precinct.find_or_create_by(name: row['precinct'], county: county)
      candidate = Candidate.find_or_create_by(name: row['candidate'], party: row['party'], normalized_name: row['candidate_normalized'], fec_id: row['candidate_fec'], office: office)
      Result.create(total: row['votes'], state: state, county: county, precinct: precinct, candidate: candidate)
    end
  end
end
seed_state

# def export_margins
#   formatted_hash = []
#   for_export = []
#   top_three = Result.includes(:candidate).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
#   candidate_results = Result.includes(:candidate, :state)
#   major_results = candidate_results.where(candidate_id: top_three).order('states.fips').group(['states.fips', 'candidates.id']).sum(:total)
#   other_results = candidate_results.where.not(candidate_id: top_three).order('states.fips').group('states.fips').sum(:total)
#   county_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
#   other_results.delete_if { |k, v| !county_results.include?(k) }
#   county_results.keys.each do |county_id|
#     county_results[county_id] ||= [:other]
#     county_results[county_id][:other] ||= other_results[county_id].to_i
#     formatted_hash <<  Hash[id: county_id, results: county_results[county_id]]
#   end
#   formatted_hash.each do |county|
#     county_total = county[:results].values.inject(0) { |sum, n | sum + n }
#     fips = county[:id].to_s.rjust(2, '0')
#     clinton_votes = county[:results][16]
#     clinton_percent = county[:results][16] / county_total.to_f
#     trump_votes = county[:results][10]
#     trump_percent = county[:results][10] / county_total.to_f
#     clinton_margin = clinton_percent - trump_percent
#     johnson_votes = !county[:results][14].nil? ? county[:results][14] : 0
#     johnson_percent = !county[:results][14].nil? ? county[:results][14] / county_total.to_f : 0.0
#     other_votes = !county[:results][:other].nil? ? county[:results][:other] : 0
#     other_percent = !county[:results][:other].nil? ? county[:results][:other] / county_total.to_f : 0.0

#     for_export << { fips: fips, clinton_votes: clinton_votes, clinton_percent: clinton_percent, clinton_margin: clinton_margin, trump_votes: trump_votes, trump_percent: trump_percent, johnson_votes: johnson_votes, johnson_percent: johnson_percent, other_votes: other_votes, other_percent: other_percent }
#   end
#   CSV.open("statewide_results.csv", "wb") do |csv|
#     csv << for_export.first.keys
#     for_export.each do |data|
#       csv << data.values
#     end
#   end
# end
