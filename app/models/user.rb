class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :trips, dependent: :destroy
  has_many :emergency_contacts, dependent: :destroy
  has_many :checklists, through: :trips

  validates :email, presence: true, if: :active?
  validates :password, presence: true, length: { minimum: 6 }
  validates :first_name, presence: true, if: :active?
  validates :last_name, presence: true, if: :active?

  def active?
    active == true
  end
end
