class Trip < ApplicationRecord
  belongs_to :user
  belongs_to :trail
  belongs_to :emergency_contact
  has_many :checklists, dependent: :destroy
  has_many :checkpoints, through: :trail
  has_many :items, through: :checklists
  has_one_attached :photo

  validates :start_date, presence: false
  validates :end_date, presence: false
  validates :no_of_people, presence: false
  validates :status, presence: false
  validates :cooking, presence: false
  validates :camping, presence: false
  validates :last_seen_photo, presence: false
  validates :release_date_time, presence: false
  validates :emergency_contact, presence: false

end
