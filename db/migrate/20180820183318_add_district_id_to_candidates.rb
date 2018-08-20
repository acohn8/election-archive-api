class AddDistrictIdToCandidates < ActiveRecord::Migration[5.2]
  def change
    add_column :candidates, :district_id, :integer
  end
end
