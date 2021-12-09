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

    authorize @trip
    redirect_to steps_path(trail_id: @trail.id)
  end

  def show
    @trip = Trip.find(params[:id])
    @trip_days = (@trip.end_date - @trip.start_date).to_i + 1
    @trip_dates = @trip.checkpoints.map { |point| point.trip_date(@trip) }
    @category_items = %w[backpack_gear kitchen_tools food_water clothes_footwear navigation first_aid hygiene]

    @markers = []
    @elevation_arr = []
    coordinates = @trip.trail.checkpoints

    coordinates.each_with_index do |coordinate, index|
      @markers << {
        lat: coordinate.latitude,
        lng: coordinate.longitude,
        info_window: render_to_string(partial: "trails/info_window", locals: { trail: @trip.trail })
      }

      if index === 0
        @elevation_arr << ["start", coordinate.elevation]
      elsif index === coordinates.count - 1
        @elevation_arr << ["end", coordinate.elevation]
      else
        @elevation_arr << ["checkpoint#{index + 1}", coordinate.elevation]
      end
      max = @elevation_arr.max { |a, b| a[1] <=> b[1] }
      @max_no = (max[1] + 100).to_s
      min = @elevation_arr.min { |a, b| a[1] <=> b[1] }
      @min_no = min[1].to_s
    end

    authorize @trip
  end

  private

  def create_tmp_user
    User.where(email: "placeholder@email.com").first
  end
end
