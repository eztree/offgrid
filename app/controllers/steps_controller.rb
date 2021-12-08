class StepsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  before_action :assign_trip, only: [:show, :update]
  before_action :assign_emergency_contact, only: [:show, :update]

  include Wicked::Wizard
  steps :date_people, :options, :emergency_contact

  def show
    render_wizard
  end

  def update
    @user = find_user
    case step
    when :date_people
      if trips_params
        @trip.start_date = trips_params[:start_date]
        @trip.no_of_people = trips_params[:no_of_people]
      end
    when :options
      if trips_params
        @trip.camping = trips_params[:camping]
        @trip.cooking = trips_params[:cooking]
        @trip.save
      end
    when :emergency_contact
      raise
    end
    render_wizard @trip
  end

  private

  def assign_trip
    @trip = Trip.find(params[:trip_id])
  end

  def trips_params
    params.require(:trip)
          .permit(:start_date, :no_of_people, :camping, :cooking, :release_date_time, :end_date, :status)
  end

  def find_user
    @user = current_user.nil? ? @trip.user : current_user
  end

  def assign_emergency_contact
    find_user
    @emergency_contact = @user.emergency_contacts.present? ? @user.emergency_contacts : EmergencyContact.new
  end

end
