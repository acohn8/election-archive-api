require 'csv'


def create_counties
  data = CSV.open("/Users/adamcohn/Documents/development/projects/election_data/state-level-results/2016-co-precinct.csv", headers: :first_row).map(&:to_h)
  filtered_data = data.select{ |row| row['office'] == 'US President'}
  filtered_data.each do |row|
    puts row
    state = State.find_or_create_by(name: row['state'], short_name: row['state_postal'], fips: row['state_fips'])
    county = County.find_or_create_by(name: row['county_name'], fips: row['county_fips'], state: state)
    precinct = Precinct.find_or_create_by(name: row['precinct'], county: county)
    candidate = Candidate.find_or_create_by(name: row['candidate'], party: row['party'], normalized_name: row['candidate_normalized'], writein: row['writein'], fec_id: row['candidate_fec'], google_id: row['candidate_google'], govtrack_id: row['candidate_govtrack'], opensecrets_id: row['candidate_opensecrets'], wikidata_id: row['candidate_wikidata'])
    Result.create(total: row['votes'], precinct: precinct, candidate: candidate)
  end
end

create_counties
