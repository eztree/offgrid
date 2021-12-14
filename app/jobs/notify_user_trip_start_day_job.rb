class NotifyUserTripStartDayJob < ApplicationJob
  queue_as :default

  def perform(trip_id)
    # Find Trip
    trip = Trip.find(trip_id)
    puts trip

    # change status to "ongoing"
    trip.status = "ongoing"
    if trip.save
      # message to the user
      TwilioTextMessenger.new(
        message: "OffGrid - Your trip to #{trip.trail.location} (#{trip.trail.name}) is today! Remember to reply RETURN to this number once you're back! #{trip.emergency_contact.name} will be notified of your return too!",
        receiver: trip.user.phone_no
      ).call
    else
      puts "There was an error updating the trip."
    end
  end
end
