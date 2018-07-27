require 'csv'


#exceptions:
#NH cities
#AK boroughs
#AL Party-line voting appears in the data as office values of Straight Party and candidate values of, for example, Alabama Republican Party. To calculate vote totals, sum the votes candidates' received on their own lines and from party-line voting.

#add precinct column to state

#find by race/close spellings

def seed_state
  # data = CSV.open(File.join(Rails.root, 'db/seed_data/2016-wi-precinct.csv'), headers: :first_row).map(&:to_h)
  states = ['al', 'ak', 'ar', 'ca', 'ct', 'dc', 'de', 'hi', 'id', 'il']
  states.each do |state|
    data = CSV.open("/Users/adamcohn/Documents/development/projects/election_data/precinct-returns/source/2016-#{state}-precinct.csv", headers: :first_row).map(&:to_h)
    filtered_data = data.select{ |row| row['office'] == 'US President'}
    filtered_data.each do |row|
      puts "#{row['candidate']}, #{row['county_name']}"
      state = State.find_or_create_by(name: row['state'], short_name: row['state_postal'], fips: row['state_fips'])
      county = County.find_or_create_by(name: row['county_name'], fips: row['county_fips'], latitude: row['county_lat'], longitude: row['county_long'], state: state)
      precinct = Precinct.find_or_create_by(name: row['precinct'], county: county)
      candidate = Candidate.find_or_create_by(normalized_name: row['candidate_normalized'], fec_id: row['candidate_fec'])
      Result.create(total: row['votes'], state: state, county: county, precinct: precinct, candidate: candidate)
    end
  end
end

seed_state