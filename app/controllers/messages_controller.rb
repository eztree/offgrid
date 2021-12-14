class MessagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  skip_before_action :verify_authenticity_token, only: [:receive_sms]

  def receive_sms
    respond_to do |format|
      response = Twilio::TwiML::MessagingResponse.new do |r|
        r.message body: generate_response(params)
      end
      format.xml { render xml: response.to_s, content_type: 'text/xml' }
    end
  end

  private

  def generate_response(params)
    sender_number = params["From"]
    User.exists?(phone_no: sender_number) ? process_sms(params) : "Offgrid - Phone Number not in Offgrid Database"
  end

  def process_sms(params)
    message_words = params["Body"].split
    case message_words.first.upcase
    # when "TRIPSTART"
    #   start_trip(params)
    when "RETURN"
      return_trip(params)
    else
      return "Offgrid - Command Not Recognized"
    end
  end

  def return_trip(params)
    sender = User.find_by(phone_no: params["From"])
    trip = Trip.find_by(user: sender, status: "ongoing")
    unless trip.nil?
    trip.status = "return"
      if trip.save
        NotifyEmergencyContactsUserReturnJob
          .set(wait: 5.second)
          .perform_later(trip.id)
        return "OffGrid - Welcome back! Hope your trip at #{trip.trail.location} was great!"
      else
        return "OffGrid - There was an error returning from your trip."
      end
    else
      return "OffGrid - You have no trips to return from."
    end
  end
end
