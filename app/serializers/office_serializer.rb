class OfficeSerializer < ActiveModel::Serializer
  attributes :id, :name, :state_map, :county_map
end
