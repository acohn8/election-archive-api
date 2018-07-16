class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :results do |t|
      t.integer :total
      t.integer :candidate_id
      t.integer :precinct_id
      t.timestamps
    end
  end
end
