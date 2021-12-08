class Checkpoint < ApplicationRecord
  attr_accessor :date

  belongs_to :trail

  # create relationship between checkpoints
  belongs_to :previous_checkpoint, class_name: 'Checkpoint', optional: true
  has_one :next_checkpoint, :class_name => 'Checkpoint', :foreign_key => 'previous_checkpoint_id', required: false, dependent: :nullify

  def is_start?
    previous_checkpoint.nil?
  end

  def trip_date(trip)
    if self.is_start?
      trip.start_date
    else
      previous_checkpoint.trip_date(trip) + 1
    end
  end
end
