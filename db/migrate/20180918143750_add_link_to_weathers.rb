class AddLinkToWeathers < ActiveRecord::Migration[5.2]
  def change
    add_column :weathers, :link, :string
  end
end
