class AddStateIdToOffices < ActiveRecord::Migration[5.2]
  def change
    add_column :offices, :state_id, :integer
  end
end
