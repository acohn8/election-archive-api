class AddMapIdsToOffices < ActiveRecord::Migration[5.2]
  def change
    add_column :offices, :state_map, :string
    add_column :offices, :county_map, :string
  end
end
