class DropStateOffice < ActiveRecord::Migration[5.2]
  def change
    drop_table :state_offices
  end
end
