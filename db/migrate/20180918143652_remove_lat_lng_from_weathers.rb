class RemoveLatLngFromWeathers < ActiveRecord::Migration[5.2]
  def change
      def change
        remove_column :weathers, :lat, :decimal
        remove_column :weathers, :lng, :decimmal
      end
  end
end
