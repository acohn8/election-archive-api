class CreateDistricts < ActiveRecord::Migration[5.2]
  def change
    create_table :districts do |t|
      t.string :name
      t.integer :office_id

      t.timestamps
    end
  end
end
