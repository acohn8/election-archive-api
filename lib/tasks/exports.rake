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
  task geo_export: :environment do
    formatted_hash = []
    Office.find(309).states.distinct.to_a.each do |state|
      top_two = state.results.includes(:candidate).where(candidates: { office_id: 309 }).group('candidates.id').sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0..3].map{|k, v| k }
      candidate_results = state.results.includes(:county, :candidate).where(candidates: {office_id: 309})
      major_results = candidate_results.where(candidate_id: top_two).order('counties.id').group(['counties.id', 'candidates.id']).sum(:total)
      county_results = major_results.reduce({}){|v, (k, x)| v.merge!(k[0] => {k[1] => x}){|_, o, n| o.merge!(n)}}
      state_counties = state.counties.distinct.to_a
      state_candidates = state.candidates.distinct.to_a
      puts state.name
      county_results.keys.each do |county_id|
        county = state_counties.find { |c| c.id == county_id }
        candidate_totals = county_results[county_id].transform_keys { |k| state_candidates.find { |c| c.id == k }.party }
        county_total = candidate_results.select { |r| r.county_id == county_id }.map(&:total).inject(&:+)
        if !candidate_totals['democratic'].nil? && !candidate_totals['republican'].nil?
          dem_margin = (candidate_totals['democratic'] / county_total.to_f) - (candidate_totals['republican'] / county_total.to_f)
          formatted_hash << { GEOID: county.fips.to_s.rjust(5, '0'), state_id: state.id, state_fips: state.fips.to_s.rjust(2, '0'), dem_margin: dem_margin, dem_votes: candidate_totals['democratic'], gop_votes: candidate_totals['republican'] }
        elsif candidate_totals['democratic'].nil? && !candidate_totals['republican'].nil?
          dem_margin = -1
          formatted_hash << { GEOID: county.fips.to_s.rjust(5, '0'), state_id: state.id, state_fips: state.fips.to_s.rjust(2, '0'), dem_margin: dem_margin, dem_votes: 0, gop_votes: candidate_totals['republican'] }
        elsif !candidate_totals['democratic'].nil? && candidate_totals['republican'].nil?
          dem_margin = 1
          formatted_hash << { GEOID: county.fips.to_s.rjust(5, '0'), state_id: state.id, state_fips: state.fips.to_s.rjust(2, '0'), dem_margin: dem_margin, dem_votes: candidate_totals['democratic'], gop_votes: 0 }
        end
      end
    end
    CSV.open("./exports/senate-results", "wb") do |csv|
      csv << formatted_hash.first.keys
      formatted_hash.each do |county|
        csv << county.values
      end
    end
  end
end