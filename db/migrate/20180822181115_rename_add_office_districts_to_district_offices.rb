class RenameAddOfficeDistrictsToDistrictOffices < ActiveRecord::Migration[5.2]
  def change
    rename_table :add_office_districts, :office_districts
  end
end
