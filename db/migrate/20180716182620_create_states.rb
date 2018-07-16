class CreateStates < ActiveRecord::Migration[5.2]
  def change
    create_table :states do |t|
      t.string :name
      t.string :short_name
      t.integer :fips

      t.timestamps
    end
  end
end
