class CountySerializer < ActiveModel::Serializer
  attributes :id, :name, :fips, :latitude, :longitude
  belongs_to :state
end
