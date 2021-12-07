class Trip < ApplicationRecord
  belongs_to :user
  belongs_to :trail

  validates :start_date, presence: false
  validates :end_date, presence: false
  validates :no_of_people, presence: false
  validates :status, presence: false
  validates :cooking, presence: false
  validates :camping, presence: false
  validates :last_seen_photo, presence: false
  validates :release_date_time, presence: false

end
