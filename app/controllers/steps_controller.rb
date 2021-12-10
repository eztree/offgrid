class StepsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  before_action :find_user, only: [:show, :update]

  include Wicked::Wizard
  steps :date_people, :options, :emergency_contact

  def show
    case step
    when :date_people
      @trip = Trip.new(trail: @trail)
      session[:trip] = nil
    else
      @trip = Trip.new(session[:trip])
    end
    render_wizard
  end

  def update
    case step
    when :date_people
      if params[:trip][:start_date].empty? || params[:trip][:no_of_people].empty?
        flash[:notice] = "Please fill in all fields"
        redirect_to wizard_path
        return
      end
      trail = Trail.find(session[:trail_id])
      @trip = Trip.new(trip_params)
      @trip.trail = trail
      session[:trip] = @trip.attributes
      redirect_to next_wizard_path
      return
    when :options
      session[:trip] = session[:trip].merge(trip_params)
      @trip = Trip.new(session[:trip])
      redirect_to next_wizard_path
      return
    when :emergency_contact
      unless params[:trip].present?
        flash[:notice] = "Please pick an emergency contact"
        redirect_to wizard_path
        return
      end
      @trip = Trip.new(session[:trip])
      if current_user.emergency_contacts.present?
        @emergency_contact = EmergencyContact.find(params[:trip][:emergency_contact_id])
      else
        @emergency_contact = EmergencyContact.new(emergency_contact_params)
        @emergency_contact.user = @user
        @emergency_contact.save
      end
      @trip.emergency_contact = @emergency_contact
      end_time = parse_end_time(@trip)
      @trip.status = "upcoming"
      @trip.end_date = end_time
      @trip.user = @user
      if @trip.save
        assign_checklist(@trip)
        redirect_to user_trip_path(id: @trip.id, user_id: @user)
        session.delete(:trip)
        session.delete(:trail_id)
      end
    end
  end

  private

  def trip_params
    params.require(:trip)
          .permit(:start_date, :no_of_people, :camping, :cooking, :release_date_time, :end_date, :status)
  end

  def emergency_contact_params
    params.require(:emergency_contact)
          .permit(:name, :email, :phone_no)
  end

  def find_user
    @user = current_user || @trip.user
  end

  def parse_end_time(trip)
    start_date = trip.start_date
    time_req = trip.trail.time_needed
    time_req = time_req.split(/D/).first.to_i
    @end_date = start_date + time_req
  end

  def assign_checklist(trip)
    items = Item.tagged_with("required")
    items.each do |item|
      Checklist.create(trip: trip, checked: false, item: item)
    end
  end
end
