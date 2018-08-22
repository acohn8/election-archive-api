class RemoveOfficeIdFromDistricts2 < ActiveRecord::Migration[5.2]
  def change
    remove_column :districts, :office_id, :integer
  end
end
