class EmergencyContact < ApplicationRecord
  belongs_to :user
  has_many :trips

  validates :name, presence: false
  validates :email, presence: false
  validates :phone_no, presence: false
end
