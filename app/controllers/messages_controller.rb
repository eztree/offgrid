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
    message_words = params["Body"].split
    sender_number = params["From"]
    if User.exists?(phone_no: sender_number)
      return "User in DB, Received: #{params["Body"]}"
    else
      return "Phone Number not in Offgrid Database. Received: #{params["Body"]}"
    end
  end
end
