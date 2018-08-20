class CreateStateOffices < ActiveRecord::Migration[5.2]
  def change
    create_table :state_offices do |t|
      t.integer :state_id
      t.integer :office_id

      t.timestamps
    end
  end
end
