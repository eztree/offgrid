class Trail < ApplicationRecord
  has_many :checkpoints, dependent: :destroy
  has_many :trips, dependent: :destroy
end
