require 'fileutils'

namespace :exports do
  desc "creates directories for exports"
  task make_directories: :environment do
    State.all.each do |state|
      state.offices.distinct.each do |office|
        Dir.mkdir("./exports/#{state.short_name.downcase}") unless File.exists?("./exports/#{state.short_name.downcase}")
        Dir.mkdir("./exports/#{state.short_name.downcase}/#{office.name.downcase.split(' ').join('_')}") unless File.exists?("./exports/#{state.short_name.downcase}/#{office.name.downcase.split(' ').join('_')}")
        Dir.mkdir("./exports/#{state.short_name.downcase}/#{office.name.downcase.split(' ').join('_')}/precincts") unless File.exists?("./exports/#{state.short_name.downcase}/#{office.name.downcase.split(' ').join('_')}/precincts")
        Dir.mkdir("./exports/#{state.short_name.downcase}/#{office.name.downcase.split(' ').join('_')}/counties") unless File.exists?("./exports/#{state.short_name.downcase}/#{office.name.downcase.split(' ').join('_')}/counties")
      end
    end
  end

  desc "exports precinct results"
  task precinct_export: :environment do
    State.all.each do |state|
      state.offices.distinct.each do |office|
        formatted_hash = []
        top_three = state.results.includes(:candidate).where(candidates: { office_id: office.id }).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
        candidate_results = state.results.includes(:precinct, :candidate).where(candidates: {office_id: office.id})
        major_results = candidate_results.where(candidate_id: top_three).order('precincts.id').group(['precincts.id', 'candidates.id']).sum(:total)
        other_results = candidate_results.where.not(candidate_id: top_three).order('precincts.id').group('precincts.id').sum(:total)
        precinct_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
        state_counties = state.counties.distinct.to_a
        state_candidates = state.candidates.distinct.to_a
        state_precincts = state.precincts.distinct.to_a
        other_results.delete_if { |k, v| !precinct_results.include?(k) }
        precinct_results.keys.each do |precinct_id|
          precinct = state_precincts.find { |p| p.id == precinct_id }
          county = state_counties.find { |c| c.id == precinct.county_id }
          candidate_totals = precinct_results[precinct_id].transform_keys { |k| state_candidates.find { |c| c.id == k }.name }
          candidate_totals[:other] ||= other_results[precinct_id]
          result = { precinct: precinct.name, precinct_county: county.name, county_fips: county.fips }.merge(candidate_totals)
          formatted_hash << result
        end
        CSV.open("./exports/#{state.short_name.downcase}/#{office.name.downcase.split(' ').join('_')}/precincts/#{state.short_name.downcase}_#{office.name.downcase.split(' ').join('_')}_precinct_results.csv", "wb") do |csv|
          csv << formatted_hash.first.keys
          formatted_hash.each do |precinct|
            csv << precinct.values
          end
        end
      end
    end
  end

  desc "exports county results"
  task county_export: :environment do
    State.all.each do |state|
      state.offices.distinct.each do |office|
        formatted_hash = []
        top_three = state.results.includes(:candidate).where(candidates: { office_id: office.id }).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..2].map{|k, v| k }
        candidate_results = state.results.includes(:county, :candidate).where(candidates: {office_id: office.id})
        major_results = candidate_results.where(candidate_id: top_three).order('counties.id').group(['counties.id', 'candidates.id']).sum(:total)
        other_results = candidate_results.where.not(candidate_id: top_three).order('counties.id').group('counties.id').sum(:total)
        county_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
        state_counties = state.counties.distinct.to_a
        state_candidates = state.candidates.distinct.to_a
        other_results.delete_if { |k, v| !county_results.include?(k) }
        county_results.keys.each do |county_id|
          county = state_counties.find { |c| c.id == county_id }
          candidate_totals = county_results[county_id].transform_keys { |k| state_candidates.find { |c| c.id == k }.name }
          candidate_totals[:other] ||= other_results[county_id]
          result = { county: county.name, fips: county.fips }.merge(candidate_totals)
          formatted_hash << result
        end
        CSV.open("./exports/#{state.short_name.downcase}/#{office.name.downcase.split(' ').join('_')}/counties/#{state.short_name.downcase}_#{office.name.downcase.split(' ').join('_')}_county_results.csv", "wb") do |csv|
          csv << formatted_hash.first.keys
          formatted_hash.each do |county|
            csv << county.values
          end
        end
      end
    end
    county_results_export
  end

  desc "exports county results with fips for mapping"
  task geo_export_county: :environment do
    Office.all.where.not(id: 322).each do |office|
      formatted_hash = []
      office.states.distinct.to_a.each do |state|
        puts "#{state.name}, #{office.name}"
        top_candidates = state.results.includes(:candidate).where(candidates: { office_id: office.id }).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..1].map{|k, v| k }
        candidate_results = state.results.includes(:county, :candidate).where(candidates: {office_id: office.id})
        major_results = candidate_results.where(candidate_id: top_candidates).order('counties.id').group(['counties.id', 'candidates.id']).sum(:total)
        county_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
        state_counties = state.counties.distinct.to_a
        state_candidates = state.candidates.distinct.to_a
        winner = state_candidates.find {|c| c.id == top_candidates[0] }
        second = state_candidates.find {|c| c.id == top_candidates[1] }
        county_results.keys.each do |county_id|
          county = state_counties.find { |c| c.id == county_id }
          candidate_totals = county_results[county_id]
          party_totals = candidate_totals.transform_keys { |k| state_candidates.find { |c| c.id == k }.party }
          county_total = candidate_results.select { |r| r.county_id == county_id }.map(&:total).inject(&:+)
          countyInfo = {}
          countyInfo[:GEOID] ||= county.fips.to_s.rjust(5, '0')
          countyInfo[:winner_name] ||= winner.name
          countyInfo[:winner_party] ||= winner.party
          countyInfo[:winner_votes] ||= candidate_totals[winner.id]
          countyInfo[:winner_margin] ||= candidate_totals[winner.id].to_f / county_total.to_f
          countyInfo[:second_name] ||= second.name
          countyInfo[:second_party] ||= second.party
          countyInfo[:second_votes] ||= candidate_totals[second.id]
          countyInfo[:second_margin] ||= candidate_totals[second.id].to_f / county_total.to_f
          if !party_totals['democratic'].nil? && !party_totals['republican'].nil?
            countyInfo[:dem_margin] = (party_totals['democratic'] / county_total.to_f) - (party_totals['republican'] / county_total.to_f)
          elsif party_totals['democratic'].nil? && !party_totals['republican'].nil?
            countyInfo[:dem_margin] = -1
          elsif !party_totals['democratic'].nil? && party_totals['republican'].nil?
            countyInfo[:dem_margin] = 1
          end
          formatted_hash << countyInfo
        end
      end
      CSV.open("./exports/#{office.name.split(' ').join('-')}-county-results.csv", "wb") do |csv|
        csv << formatted_hash.first.keys
        formatted_hash.each do |county|
          csv << county.values
        end
      end
    end
  end

  desc "exports state results with fips for mapping"
  task geo_export_state: :environment do
    Office.all.where.not(id: 322).each do |office|
      formatted_hash = []
      office.states.distinct.to_a.each do |state|
        puts "#{state.name}, #{office.name}"
        top_candidates = state.results.includes(:candidate).where(candidates: { office_id: office.id }).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..1].map{|k, v| k }
        candidate_results = state.results.includes(:candidate).where(candidates: {office_id: office.id})
        major_results = candidate_results.where(candidate_id: top_candidates).group('candidates.id').sum(:total)
        state_candidates = state.candidates.distinct.where(candidates: {office_id: office.id }).to_a
        candidate_totals = major_results.transform_keys { |k| state_candidates.find { |c| c.id == k }.party }
        state_total = candidate_results.map(&:total).inject(&:+)
        winner = state_candidates.find {|c| c.id == top_candidates[0] }
        second = state_candidates.find {|c| c.id == top_candidates[1] }
        state_info = {}
        state_info[:STATEFP] ||= state.fips.to_s.rjust(2, '0')
        state_info[:winner_name] ||= winner.name
        state_info[:winner_party] ||= winner.party
        state_info[:winner_votes] ||= major_results[winner.id]
        state_info[:winner_margin] ||= major_results[winner.id].to_f / state_total.to_f
        state_info[:second_name] ||= second.name
        state_info[:second_party] ||= second.party
        state_info[:second_votes] ||= major_results[second.id]
        state_info[:second_margin] ||= major_results[second.id].to_f / state_total.to_f
        if !candidate_totals['democratic'].nil? && !candidate_totals['republican'].nil?
          state_info[:dem_margin] = (candidate_totals['democratic'] / state_total.to_f) - (candidate_totals['republican'] / state_total.to_f)
        elsif candidate_totals['democratic'].nil? && !candidate_totals['republican'].nil?
          state_info[:dem_margin] = -1
        elsif !candidate_totals['democratic'].nil? && candidate_totals['republican'].nil?
          state_info[:dem_margin] = 1
        end
        formatted_hash << state_info
      end
      CSV.open("./exports/#{office.name.split(' ').join('-')}-state-results.csv", "wb") do |csv|
        csv << formatted_hash.first.keys
        formatted_hash.each do |county|
          csv << county.values
        end
      end
    end
  end

  desc "exports congressional results with fips for mapping"
  task geo_export_congressional: :environment do
    formatted_hash = []
    to_check = []
    State.all.each do |state|
      state_districts = state.districts.joins(:offices).where(offices: { id: 322 }).to_a
      state_districts.each do |district|
        puts district.name
        results = district.results.group(:candidate_id).sum(:total)
        top_candidates = results.sort{|a,b| a[1]<=>b[1]}.reverse[0..1].map{|k, v| k }
        top_results = {}
        top_candidates.each {|id| top_results[id] ||= results[id] }
        district_total = results.values.inject(&:+)
        candidates = district.candidates.to_a
        winner = candidates.find {|c| c.id == top_candidates[0] }
        second = candidates.find {|c| c.id == top_candidates[1] }
        party_totals = {}
        if !second.nil?
          party_totals = top_results.transform_keys { |k| candidates.find { |c| c.id == k }.party}
        else
          party_totals[winner.party] ||= top_results[winner.id]
        end
        district_info = {}
        district_info[:GEOID] ||= "#{state.fips.to_s.rjust(2, '0')}#{district.name.split('-').last}"
        district_info[:NAME] ||= district.name
        district_info[:id] ||= district.id
        district_info[:winner_name] ||= winner.name
        district_info[:winner_party] ||= winner.party
        district_info[:winner_votes] ||= results[winner.id]
        district_info[:winner_margin] ||= results[winner.id].to_f / district_total.to_f
        !second.nil? ? district_info[:second_name] ||= second.name : district_info[:second_name] ||= 'UNOPPOSED'
        !second.nil? ? district_info[:second_party] ||= second.party : district_info[:second_party] ||= 'N/A'
        !second.nil? ? district_info[:second_votes] ||= results[second.id] : district_info[:second_votes] ||= 0
        !second.nil? ? district_info[:second_margin] ||= results[second.id].to_f / district_total.to_f : district_info[:second_margin] ||= 0.0
        if !party_totals['democratic'].nil? && !party_totals['republican'].nil?
          district_info[:dem_margin] = (party_totals['democratic'] / district_total.to_f) - (party_totals['republican'] / district_total.to_f)
        elsif party_totals['democratic'].nil? && !party_totals['republican'].nil?
          district_info[:dem_margin] = -1
          second_name = !second.nil? ? second.name : nil
          second_party =  !second.nil? ? second.party : nil
          to_check << { name: district.name, winner: winner.name, winner_party: winner.party, second_name: second_name, second_party: second_party }
          to_check << { name: district.name }
        elsif !party_totals['democratic'].nil? && party_totals['republican'].nil?
          district_info[:dem_margin] = 1
          second_name = !second.nil? ? second.name : nil
          second_party =  !second.nil? ? second.party : nil
          to_check << { name: district.name, winner: winner.name, winner_party: winner.party, second_name: second_name, second_party: second_party }
        end
        formatted_hash << district_info
      end
    end
    formatted_hash << { GEOID: '1224', name: 'FL-24', id: 0, winner_name: 'Frederica Wilson', winner_party: 'democratic', winner_votes: 100, winner_margin: 1, second_name: 'UNOPPOSED', second_party: 'N/A', second_votes: 0, second_margin: 0, dem_margin: 1 }
    formatted_hash << { GEOID: '4001', name: 'OK-01', id: 0, winner_name: 'Jim Bridenstine', winner_party: 'republican', winner_votes: 100, winner_margin: 1, second_name: 'UNOPPOSED', second_party: 'N/A', second_votes: 0, second_margin: 0, dem_margin: -1 }
    formatted_hash << { GEOID: '4808', name: 'TX-08', id: 0, winner_name: 'Kevin Brady', winner_party: 'republican', winner_votes: 100, winner_margin: 1, second_name: 'UNOPPOSED', second_party: 'N/A', second_votes: 0, second_margin: 0, dem_margin: -1 }
    CSV.open("./exports/house-results.csv", "wb") do |csv|
      csv << formatted_hash.first.keys
      formatted_hash.each do |county|
        csv << county.values
      end
    end
    CSV.open("./exports/to-check.csv", "wb") do |csv|
      csv << to_check.first.keys
      to_check.each do |county|
        csv << county.values
      end
    end
  end
end