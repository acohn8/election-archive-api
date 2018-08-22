class AddDistrictIdToStateOffices < ActiveRecord::Migration[5.2]
  def change
    add_column :state_offices, :district_id, :integer
  end
end
