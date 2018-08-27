class AddIndexToResult < ActiveRecord::Migration[5.2]
  def change
    add_index :results, :state_id
  end
end
