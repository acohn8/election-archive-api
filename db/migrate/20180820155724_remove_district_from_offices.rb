class RemoveDistrictFromOffices < ActiveRecord::Migration[5.2]
  def change
    remove_column :offices, :district, :string
  end
end
