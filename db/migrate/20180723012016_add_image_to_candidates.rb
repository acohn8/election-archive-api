class AddImageToCandidates < ActiveRecord::Migration[5.2]
  def change
    add_column :candidates, :image, :string
  end
end
