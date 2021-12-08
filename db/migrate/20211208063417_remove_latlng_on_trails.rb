class RemoveLatlngOnTrails < ActiveRecord::Migration[6.1]
  def change
    remove_column :trails, :start_lon
    remove_column :trails, :end_lon
    remove_column :trails, :start_lat
    remove_column :trails, :end_lat
  end
end
