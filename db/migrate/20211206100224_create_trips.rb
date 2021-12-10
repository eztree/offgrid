class CreateTrips < ActiveRecord::Migration[6.1]
  def change
    create_table :trips do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.integer :no_of_people
      t.references :trail, null: false, foreign_key: true
      t.string :status, default: 'upcoming'
      t.boolean :cooking
      t.boolean :camping
      t.string :last_seen_photo
      t.datetime :release_date_time

      t.timestamps
    end
  end
end
