class TripsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  def index
    @trips = policy_scope(Trip)
    authorize @trips
  end

  def new
    @trail = Trail.find(params['trail_id'])
    @user = current_user.nil? ? create_tmp_user : current_user

    @trip = Trip.new(
      user: @user,
      trail: @trail
    )
    session[:trail_id] = @trail.id
    authorize @trip
    redirect_to steps_path
  end

  def show
    @trip = Trip.find(params[:id])
    @trip_days = (@trip.end_date - @trip.start_date).to_i + 1
    @trip_dates = @trip.checkpoints.map { |point| point.trip_date(@trip) }
    @category_items = %w[backpack_gear kitchen_tools food_water clothes_footwear navigation first_aid hygiene]

    @markers = []
    coordinates = @trip.trail.checkpoints

    coordinates.each do |coordinate|
      @markers << {
        lat: coordinate.latitude,
        lng: coordinate.longitude,
        info_window: render_to_string(partial: "trails/info_window", locals: { trail: @trip.trail })
      }
    end

    authorize @trip
  end

  private

  def create_tmp_user
    User.where(email: "placeholder@email.com").first
  end
end
