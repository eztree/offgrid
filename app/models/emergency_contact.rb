class EmergencyContact < ApplicationRecord
  belongs_to :user
  has_many :trips

  validates :name, presence: true
  validates :email, presence: true
  validates :phone_no, presence: true
end
