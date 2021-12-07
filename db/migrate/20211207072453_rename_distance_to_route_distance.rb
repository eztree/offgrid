class RenameDistanceToRouteDistance < ActiveRecord::Migration[6.1]
  def change
    rename_column :trails, :distance, :route_distance
  end
end
