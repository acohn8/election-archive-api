class DropDistrictOffice < ActiveRecord::Migration[5.2]
  def change
    drop_table :district_offices
  end
end
