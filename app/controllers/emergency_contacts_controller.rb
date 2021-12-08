class EmergencyContactsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  before_action :find_trip, only: [:create]

  def create
    if emergency_contact_params
      @emergency_contact = EmergencyContact.create(emergency_contact_params)
      @emergency_contact.user = current_user
      @emergency_contact.save
      @trip = @emergency_contact
      @trip.save
    end
    redirect_to trip_path(@trip)
  end

  def update
    # code
  end

  private

  def emergency_contact_params
    params.require(:emergency_contact)
          .permit(:name, :email, :phone_no)
  end

  def find_trip
    trip_id = params["emergency_contact"]['trip_id']
    @trip = Trip.find(trip_id)
  end
end
