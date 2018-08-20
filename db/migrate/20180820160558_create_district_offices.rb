class CreateDistrictOffices < ActiveRecord::Migration[5.2]
  def change
    create_table :district_offices do |t|
      t.integer :office_id
      t.integer :district_id

      t.timestamps
    end
  end
end
