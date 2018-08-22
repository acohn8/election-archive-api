class DropStateDistricts < ActiveRecord::Migration[5.2]
  def change
    drop_table :state_districts
  end
end
