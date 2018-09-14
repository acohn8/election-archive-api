class RemoveDarkskies < ActiveRecord::Migration[5.2]
  def change
    drop_table :darkskies
  end
end
