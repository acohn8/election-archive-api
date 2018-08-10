class AddOfficeIdToCandidates < ActiveRecord::Migration[5.2]
  def change
    add_column :candidates, :office_id, :integer
  end
end
