class DropOfficeDistricts < ActiveRecord::Migration[5.2]
  def change
    drop_table :office_districts
  end
end
