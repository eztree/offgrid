class EmergencyContact < ApplicationRecord
  belongs_to :user
  has_many :safety_records, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true
  validates :phone_no, presence: true
end
