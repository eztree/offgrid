class Item < ApplicationRecord
  validates :name, presence: true

  acts_as_taggable_on :tags
end
