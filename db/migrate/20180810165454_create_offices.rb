class CreateOffices < ActiveRecord::Migration[5.2]
  def change
    create_table :offices do |t|
      t.string :name
      t.string :district
      t.integer :candidate_id

      t.timestamps
    end
  end
end
