class StateSerializer < ActiveModel::Serializer
  attributes :id, :name, :short_name, :fips
end
