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

#find candidates wiht the same name and office: Candidate.select(:office_id, :district_id, :normalized_name).group(:office_id, :district_id, :normalized_name).having("count(*) > 1").size
#fl-24
#ok-1
#tx-08
# def seed_state
#   states = ['sc']
#   states.each do |state|
#     data = CSV.open("/Users/adamcohn/Documents/development/projects/election_data/precinct-returns/source/2016-#{state}-precinct.csv", headers: :first_row, encoding: 'iso-8859-1:utf-8').map(&:to_h)
#     filtered_data = data.select{ |row| row['office'] == 'US House'}
#     hd = filtered_data.select { |row| row['district'] == '1'}
#     hd.each do |row|
#       puts "#{row['state_postal']}-#{row['district'].to_s.rjust(2, '0')}"
#       state = State.find_or_create_by(name: row['state'], short_name: row['state_postal'], fips: row['state_fips'])
#       office = Office.find_or_create_by(name: 'US House')
#       district = District.find_or_create_by(name: "#{row['state_postal'].downcase}-#{row['district'].to_s.rjust(2, '0')}")
#       county = County.find_or_create_by(name: row['county_name'], fips: row['county_fips'], latitude: row['county_lat'], longitude: row['county_long'], state: state)
#       precinct = Precinct.find_or_create_by(name: row['precinct'], county: county)
#       candidate = Candidate.find_or_create_by(name: row['candidate'], party: row['party'], normalized_name: row['candidate_normalized'], fec_id: row['candidate_fec'])
#       Result.create(total: row['votes'], state: state, county: county, precinct: precinct, candidate: candidate, office: office, district: district)
#     end
#   end
# end
