class AddPhotoDateToTrip < ActiveRecord::Migration[6.1]
  def change
    add_column :trips, :last_photo, :datetime
  end
end
