class AddMajorCandidateToCandidates < ActiveRecord::Migration[5.2]
  def change
    add_column :candidates, :major_candidate, :boolean
  end
end
