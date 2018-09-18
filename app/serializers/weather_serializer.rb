class WeatherSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lng
end
