class Trip < ApplicationRecord
  belongs_to :user
  belongs_to :trail
  belongs_to :emergency_contact
  has_many :checklists, dependent: :destroy
  has_many :items, through: :checklists
  has_many :checkpoints, through: :trail
  has_one_attached :photo

  has_many :emergency_contacts, through: :user

  validates :start_date, presence: true, on: :update
  validates :end_date, presence: true, on: :update
  validates :no_of_people, presence: true, on: :update
  validates :status, presence: false
  validates :cooking, presence: false, on: :update
  validates :camping, presence: false, on: :update
  validates :last_seen_photo, presence: false
  validates :release_date_time, presence: false
  validates :emergency_contact, presence: false
end
