class CreateCandidates < ActiveRecord::Migration[5.2]
  def change
    create_table :candidates do |t|
      t.string :name
      t.string :party
      t.string :normalized_name
      t.boolean :writein
      t.string :fec_id
      t.string :google_id
      t.string :govtrack_id
      t.string :opensecrets_id
      t.string :wikidata_id

      t.timestamps
    end
  end
end
