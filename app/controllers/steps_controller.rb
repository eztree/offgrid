class StepsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  before_action :find_user, only: [:show, :update]

  include Wicked::Wizard
  steps :date_people, :options, :signup, :emergency_contact

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
      if current_user.nil?
        session[:next_path] = next_wizard_path
        redirect_to next_wizard_path
        return
      end
      redirect_to wizard_path(:emergency_contact)
      return
    when :signup
      unless user_params_check(params[:user])
        flash[:notice] = "Please fill in all fields"
        redirect_to wizard_path
        return
      end
      unless user_password_check(params[:user])
        flash[:notice] = "Your passwords do not match"
        redirect_to wizard_path
        return
      end
      if user_email_check(params[:user])
        flash[:notice] = "Email has been taken"
        redirect_to wizard_path
        return
      end
      @user = User.create(user_params)
      sign_in @user
      redirect_to next_wizard_path
      return
    when :emergency_contact
      if params[:emergency_contact].present?
        if params[:emergency_contact][:name].empty? || params[:emergency_contact][:email].empty? || params[:emergency_contact][:phone_no].empty?
          flash[:notice] = "Please fill in all fields"
          redirect_to wizard_path
          return
        end
      else
        unless params[:trip][:emergency_contact_id].present?
          flash[:notice] = "Please pick an emergency contact"
          redirect_to wizard_path
          return
        end
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
        flash[:notice] = "Your trip has been created!"
        session.delete(:trip)
        session.delete(:trail_id)
        NotifyUserTripStartDayJob
          .set(wait_until: @trip.start_date.to_datetime)
          .perform_later(@trip.id)
        NotifyEmergencyContactsTripLastDayJob
          .set(wait_until: @trip.end_date.to_datetime)
          .perform_later(@trip.id)
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

  def user_params
    params.require(:user)
          .permit(:first_name, :last_name, :email, :password, :phone_no)
  end

  def user_password_check(user_params)
    user_params[:password] == user_params[:password_confirmation]
  end

  def user_params_check(user_params)
    user_params.each do |_key, value|
      return false if value.empty?
    end
    return true
  end

  def user_email_check(user_params)
    User.where(email: user_params[:email]).present?
  end

  def find_user
    @user = current_user || User.new
  end

  def parse_end_time(trip)
    start_date = trip.start_date
    time_req = trip.trail.time_needed
    time_req = time_req.split(/D/).first.to_i
    @end_date = start_date + time_req - 1
  end

  def assign_checklist(trip)
    items = Item.tagged_with(["food"], exclude: true)

    items_breakfast = Item.tagged_with("breakfast")
    items_breakfast_uncooked = Item.tagged_with("breakfast").tagged_with(["cooking"], exclude:true)

    items_lunch_dinner = Item.tagged_with("lunch_dinner") # if cooking = true
    items_lunch_dinner_uncooked = Item.tagged_with("lunch_dinner").tagged_with(["cooking"], exclude:true) # if cooking = false

    items_no_camping_no_cooking = Item.tagged_with(["camping, food, kitchen_tools"], exclude: true)
    items_utensils = Item.tagged_with(["utensils"])
    items_no_camping = Item.tagged_with(["camping, food"], exclude: true) # if camping = false
    items_no_cooking = Item.tagged_with(["kitchen_tools, food"], exclude: true) # if camping = false


    trip_days = (trip.end_date - trip.start_date).to_i + 1
    #items
    # camping false #cooking true
    if !trip.camping && trip.cooking
      # add items except for camping, food tags
      items_no_camping.each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end
      # cooking
      items_breakfast.sample(trip_days).each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end
      items_lunch_dinner.sample(trip_days * 2).each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end
    # camping false #cooking false
    elsif !trip.camping && !trip.cooking
      # add items except for camping, food, kitchen_tools tags
      items_no_camping_no_cooking.each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end

      # add utensils
      items_utensils.each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end

      # not cooking
      items_breakfast_uncooked.sample(trip_days).each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end
      items_lunch_dinner_uncooked.sample(trip_days * 2).each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end
    # camping true #cooking false
    elsif trip.camping && !trip.cooking
      items_no_cooking.each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end

      # add utensils
      items_utensils.each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end

      # not cooking
      items_breakfast_uncooked.sample(trip_days).each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end
      items_lunch_dinner_uncooked.sample(trip_days * 2).each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end
    # camping true #cooking true
    else
      items.each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end
      # cooking
      items_breakfast.sample(trip_days).each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end
      items_lunch_dinner.sample(trip_days * 2).each do |item|
        Checklist.create(trip: trip, checked: false, item: item)
      end
    end
  end
end
