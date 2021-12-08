class StepsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  before_action :assign_emergency_contact, only: [:show, :update]
  before_action :find_trails, only: [:show, :update]
  before_action :assign_trip, only: [:show, :update]

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
      end
    when :emergency_contact
      redirect_to user_emergency_contacts_path(@user)
    end
    render_wizard @trip
  end

  private

  def assign_trip
    if current_user.trips.present?
      @trip = current_user.trips.last
    else
      @trip = Trip.create(
        user: @user,
        trail: @trail,
        emergency_contact: @emergency_contact
      )
    raise

    end
  end

  def find_trails
    if  params["trail_id"].present?
      @trail = Trail.find(params["trail_id"])
    else
      @trail = @user.trips.last.trail
    end
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
    if @user.emergency_contacts.present?
      @emergency_contact = @user.emergency_contacts.first
    else
      @emergency_contact = EmergencyContact.create(user: @user)
    end
  end
end
