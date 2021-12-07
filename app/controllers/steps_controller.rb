class StepsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  before_action :assign_trip, only: [:show, :update]

  include Wicked::Wizard
  steps :add_date_and_people, :add_options, :add_emergency_contact

  def show
    @user = find_user

    render_wizard
  end

  def update
    @user = find_user
    raise
    @trip.update_attributes(params[:date])
    @trip.update_attributes(params[:no_of_people])
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

end
