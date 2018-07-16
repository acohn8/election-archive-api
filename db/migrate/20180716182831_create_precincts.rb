class CreatePrecincts < ActiveRecord::Migration[5.2]
  def change
    create_table :precincts do |t|
      t.string :name
      t.integer :state_id
      t.integer :county_id
      t.timestamps
    end
  end
end
