class Item < ApplicationRecord
  validates :name, presence: true
  has_many :unchecked, -> { where(checked: false) }, class_name: "Checklist"
  has_many :checked, -> { where(checked: true) }, class_name: "Checklist"
  has_many :checklists
  has_many :trips, through: :checklists

  acts_as_taggable_on :tags

  def self.unchecked_by_tag_name(tag_name, given_trip)
    select('items.*, checklists.id AS checklist_id, checklists.checked AS checklist_status, trips.no_of_people AS trip_people').tagged_with(tag_name).joins(unchecked: [:trip]).where(checklists: { trip: given_trip })
  end

  def self.checked_by_tag_name(tag_name, given_trip)
    select('items.*, checklists.id AS checklist_id, checklists.checked AS checklist_status, trips.no_of_people AS trip_people').tagged_with(tag_name).joins(checked: [:trip]).where(checklists: { trip: given_trip })
  end

  def self.by_tag_name(tag_name, given_trip)
    select('items.*, checklists.id AS checklist_id, checklists.checked AS checklist_status, trips.no_of_people AS trip_people').tagged_with(tag_name).joins(:trips).where(checklists: { trip: given_trip })
  end
end
