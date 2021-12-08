class CreateSafetyRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :safety_records do |t|
      t.references :emergency_contact, null: false, foreign_key: true
      t.references :trip, null: false, foreign_key: true
      t.boolean :contacted

      t.timestamps
    end
  end
end
