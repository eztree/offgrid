class Trip < ApplicationRecord
  belongs_to :user
  belongs_to :trail

  has_many :checklists
end
