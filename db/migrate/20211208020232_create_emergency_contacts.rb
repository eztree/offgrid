class CreateEmergencyContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :emergency_contacts do |t|
      t.string :name
      t.string :email
      t.string :phone_no
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
