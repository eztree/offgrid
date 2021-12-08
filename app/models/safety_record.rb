class SafetyRecord < ApplicationRecord
  belongs_to :emergency_contact
  belongs_to :trip
end
