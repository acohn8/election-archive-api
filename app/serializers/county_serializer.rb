class CountySerializer < ActiveModel::Serializer
  attributes :id, :name, :fips
  belongs_to :state
end
