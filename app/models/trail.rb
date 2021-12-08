class Trail < ApplicationRecord
  has_many :checkpoints, dependent: :destroy
  has_many :trips, dependent: :destroy
  geocoded_by :location

  def latitude
    if checkpoints.count > 0
     return checkpoints.first.latitude
    else
      return 0
    end
  end

  def longitude
    if checkpoints.count > 0
     return checkpoints.first.longitude
    else
      return 0
    end
  end
end
