class AddOfficeIdAndDistrictIdToResults < ActiveRecord::Migration[5.2]
  def change
    add_column :results, :district_id, :integer
    add_column :results, :office_id, :integer
  end
end
