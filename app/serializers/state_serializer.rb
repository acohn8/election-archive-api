class StateSerializer < ActiveModel::Serializer
  attributes :id, :name, :short_name, :fips, :precinct_map, :precinct_source
end
