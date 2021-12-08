class StepsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  before_action :find_trail
  before_action :assign_trip, only: [:show]
  before_action :assign_emergency_contact, only: [:show, :update]

  include Wicked::Wizard
  steps :date_people, :options, :emergency_contact

  def show
    raise
    render_wizard
  end

  def update
    case step
    when :date_people
      session[:trip][:start_date] = trips_params[:start_date]
      session[:trip][:no_of_people] = trips_params[:no_of_people]
    when :options
      session[:trip][:camping] = trips_params[:camping]
      session[:trip][:cooking] = trips_params[:cooking]
    when :emergency_contact
      raise
    end
    render_wizard @user
  end

  private

  def assign_trip
    session[:trip] = Trip.new
    @trip = Trip.new
  end

  def trips_params
    params.require(:trip)
          .permit(:start_date, :no_of_people, :camping, :cooking, :release_date_time, :end_date, :status)
  end

  def find_trail
    @trail = Trail.find(params[:trail_id])
  end

  def find_user
    @user = current_user.nil? ? @trip.user : current_user
  end

  def assign_emergency_contact
    find_user
    @emergency_contact = @user.emergency_contacts.present? ? @user.emergency_contacts : EmergencyContact.new
  end

  def assign_safety_record

  end

end
