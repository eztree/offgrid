class TwilioTextMessenger
  attr_reader :message, :receiver

  def initialize(attributes = {})
    @message = attributes[:message]
    @receiver = attributes[:receiver]
  end

  def call
    client = Twilio::REST::Client.new
    client.messages.create({
      from: ENV['TWILIO_PHONE_NUMBER'],
      to: receiver,
      body: message
    })
  end
end
