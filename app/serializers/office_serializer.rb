class OfficeSerializer < ActiveModel::Serializer
  attributes :id, :name, :district, :state_map, :county_map
end
