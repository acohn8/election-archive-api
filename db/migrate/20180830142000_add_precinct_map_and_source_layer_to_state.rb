class AddPrecinctMapAndSourceLayerToState < ActiveRecord::Migration[5.2]
  def change
    add_column :states, :precinct_map, :string
    add_column :states, :precinct_source, :string
  end
end
