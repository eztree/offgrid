class CreateTrails < ActiveRecord::Migration[6.1]
  def change
    create_table :trails do |t|
      t.string :name
      t.text :description
      t.string :location
      t.string :time_needed
      t.string :distance
      t.float :start_lat
      t.float :start_lon
      t.float :end_lat
      t.float :end_lon

      t.timestamps
    end
  end
end
