class AddReferencesToTrips < ActiveRecord::Migration[6.1]
  def change
    add_reference :trips, :emergency_contact, null: true, foreign_key: true
    add_column :trips, :contacted, :boolean
  end
end
