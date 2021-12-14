class NotifyEmergencyContactsUserReturnJob < ApplicationJob
  queue_as :default

  def perform(trip_id)
    trip = Trip.find(trip_id)
    trip_user = trip.user
    TwilioTextMessenger.new(
      message: "#{trip_user.first_name} #{trip_user.last_name} has returned safely from his/her trip at #{trip.trail.location}.",
      receiver: trip.emergency_contact.phone_no
    ).call
  end
end
