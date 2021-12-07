class Trail < ApplicationRecord
  has_many :checkpoints, dependent: :destroy
  has_many :trips, dependent: :destroy
  geocoded_by :location, latitude: :start_lat, longitude: :start_lon
end
