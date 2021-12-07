class StepsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  include Wicked::Wizard
  steps :add_date_and_people, :add_num_of_ppl, :add_options

  def show
    @trip = Trip.find(params[:trip_id])
    @user = @trip.user
    render_wizard
  end

  def update
    render_wizard
  end

  def add_date_and_people
    raise
  end

  def add_emergency_contact
    raise
  end

  def add_options
    raise
  end
end
