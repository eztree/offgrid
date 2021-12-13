class Checklist < ApplicationRecord
  belongs_to :trip, optional: true
  belongs_to :item, optional: true
end
