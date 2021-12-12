class NotifyUserTripStartDayJob < ApplicationJob
  queue_as :default

  def perform(trip_id)
    # Find Trip
    trip = Trip.find(trip_id)
    # message to the user
    TwilioTextMessenger.new(
      message: "OffGrid - Your trip to #{trip.trail.location} (#{trip.trail.name}) is today! Reply TRIPSTART to this SMS to start your trip!",
      receiver: trip.user.phone_no
    ).call
  end
end
