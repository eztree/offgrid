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
    User.exists?(phone_no: sender_number) ? process_sms(params) : "Phone Number not in Offgrid Database"
  end

  def process_sms(params)
    message_words = params["Body"].split
    case message_words.first.downcase
    when "start"
      start_trip(params)
    when "return"
      return_trip(params)
    else
      return "Command Not Recognized"
    end
  end

  def start_trip(params)
    sender = User.find_by(phone_no: params["From"])
    trip = Trip.find_by(start_date: Date.today, user: sender, status: "upcoming")
    unless trip.nil?
      trip.status = "ongoing"
      if trip.save!
        notify_start_to_emergency_contact(sender, trip)
        return "Your trip at #{trip.trail.location} has successfully started! Take care!"
      else
        return "There was an error starting your trip."
      end
    else
      return "You have no trips to start today."
    end
  end

  def return_trip(params)
    sender = User.find_by(phone_no: params["From"])
    trip = Trip.find_by(start_date: Date.today, user: sender, status: "ongoing")
    unless trip.nil?
    trip.status = "return"
      if trip.save
        notify_return_to_emergency_contact(sender, trip)
        return "Welcome back! Hope your trip at #{trip.trail.location} was great!"
      else
        return "There was an error returning from your trip."
      end
    else
      return "You have no trips to return from."
    end
  end

  def notify_start_to_emergency_contact(sender, trip)
    TwilioTextMessenger.new(
      message: "#{sender.first_name} #{sender.last_name} has started his/her trip at #{trip.trail.location}.",
      receiver: "+6581149852"
    ).call
  end

  def notify_return_to_emergency_contact(sender, trip)
    TwilioTextMessenger.new(
      message: "#{sender.first_name} #{sender.last_name} has returned safely from his/her trip at #{trip.trail.location}." ,
      receiver: "+6581149852"
    ).call
  end
end
