class Trail < ApplicationRecord
  has_many :checkpoints, dependent: :destroy
  has_many :trips, dependent: :destroy
  geocoded_by :location

  acts_as_taggable_on :tags

  def coordinates
    checkpoints_array = checkpoints.to_a
    if checkpoints_array.count.positive?
      { lat: checkpoints_array.first.latitude, lng: checkpoints_array.first.longitude }
    else
      { lat: 0, lng: 0 }
    end
  end

  def latitude
    coordinates[:lat]
  end

  def longitude
    coordinates[:lng]
  end

  def checkpoints_coordinates
    checkpoints_array = checkpoints.to_a
    checkpoints_array.map do |checkpoint|
      { lat: checkpoint.latitude,
        lng: checkpoint.longitude,
        name: checkpoint.name }
    end
  end
end
