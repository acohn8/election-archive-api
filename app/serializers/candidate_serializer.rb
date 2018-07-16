class CandidateSerializer < ActiveModel::Serializer
  attributes :id, :name, :party, :normalized_name, :writein, :fec_id, :google_id, :govtrack_id, :opensecrets_id, :wikidata_id
end
