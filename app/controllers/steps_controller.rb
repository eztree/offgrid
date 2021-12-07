class StepsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  before_action :assign_trip, only: [:show, :update]

  include Wicked::Wizard
  steps :add_date_and_people, :add_options, :add_emergency_contact

  def show
    @user = @trip.user
    render_wizard
  end

  def update
    @user = @trip.user
    raise

    render_wizard @user
  end

  private

  def assign_trip
    @trip = Trip.find(params[:trip_id])
  end

  def trips_params
    params.require(:user)
          .permit(:email, :current_password)
  end

end
