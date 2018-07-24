require 'csv'


#exceptions:
#NH cities
#AK boroughs
def seed_state
  data = CSV.open(File.join(Rails.root, 'db/seed_data/2016-nv-precinct.csv'), headers: :first_row).map(&:to_h)
  filtered_data = data.select{ |row| row['office'] == 'US President'}
  filtered_data.each do |row|
    puts "#{row['candidate']}, #{row['county_name']}"
    state = State.find_or_create_by(name: row['state'], short_name: row['state_postal'], fips: row['state_fips'])
    county = County.find_or_create_by(name: row['county_name'], fips: row['county_fips'], latitude: row['county_lat'], longitude: row['county_long'], state: state)
    precinct = Precinct.find_or_create_by(name: row['precinct'], county: county)
    candidate = Candidate.find_or_create_by(name: row['candidate'], party: row['party'], normalized_name: row['candidate_normalized'], writein: row['writein'], fec_id: row['candidate_fec'], google_id: row['candidate_google'], govtrack_id: row['candidate_govtrack'], opensecrets_id: row['candidate_opensecrets'], wikidata_id: row['candidate_wikidata'])
    Result.create(total: row['votes'], state: state, county: county, precinct: precinct, candidate: candidate)
  end
end

seed_state