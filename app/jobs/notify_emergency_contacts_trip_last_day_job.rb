class NotifyEmergencyContactsTripLastDayJob < ApplicationJob
  queue_as :default

  def perform(trip_id)
    # Find Trip
    trip = Trip.find(trip_id)
    # message to the user
    TwilioTextMessenger.new(
      message: "OffGrid - #{trip.user.first_name} #{trip.user.last_name} is expected to return from #{trip.trail.location} (#{trip.trail.name}) today. Ensure his/her return and contact relevant authorities in case of emergencies.",
      receiver: trip.emergency_contact.phone_no
    ).call
  end
end
