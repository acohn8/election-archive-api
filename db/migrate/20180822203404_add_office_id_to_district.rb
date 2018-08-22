class AddOfficeIdToDistrict < ActiveRecord::Migration[5.2]
  def change
    add_column :districts, :office_id, :integer
  end
end
