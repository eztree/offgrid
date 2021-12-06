class CreateCheckpoints < ActiveRecord::Migration[6.1]
  def change
    create_table :checkpoints do |t|
      t.float :latitude
      t.float :longitude
      t.integer :elevation
      t.references :trail, null: false, foreign_key: true

      t.timestamps
    end
  end
end
