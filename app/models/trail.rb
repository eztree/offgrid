class Trail < ApplicationRecord
  has_many :checkpoints, dependent: :destroy

end
