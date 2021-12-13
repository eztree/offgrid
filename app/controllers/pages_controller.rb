class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  before_action :check_useragent, only: [ :dashboard ]

  def home
    @trails = Trail.all
    redirect_to dashboard_path if user_signed_in?
  end

  def dashboard
    @trails = Trail.all
    @trips = current_user.trips
    @current_trip = @trips.first
    @trip_dates = @current_trip.checkpoints.map { |point| point.trip_date(@current_trip) } unless @current_trip.nil?

    @markers = []
    unless @current_trip.nil?
      checkpoints_data = @current_trip.trail.checkpoints_coordinates

      @coordinateString = ""
      checkpoints_data.each do |checkpoint|
        @markers << {
          lat: checkpoint[:lat],
          lng: checkpoint[:lng],
          info_window: render_to_string(partial: "trails/checkpoint_info_window", locals: { checkpoint: checkpoint })
        }
        @coordinateString += "#{checkpoint[:lng]},#{checkpoint[:lat]};"
      end
      @coordinateString = @coordinateString.chop
    end
  end

  def dashboard_mobile
    @trails = Trail.all
    @trips = current_user.trips
    @current_trip = @trips.first
    @trip_dates = @current_trip.checkpoints.map { |point| point.trip_date(@current_trip) } unless @current_trip.nil?

    @markers = []
    unless @current_trip.nil?
      checkpoints_data = @current_trip.trail.checkpoints_coordinates

      @coordinateString = ""
      checkpoints_data.each do |checkpoint|
        @markers << {
          lat: checkpoint[:lat],
          lng: checkpoint[:lng],
          info_window: render_to_string(partial: "trails/checkpoint_info_window", locals: { checkpoint: checkpoint })
        }
        @coordinateString += "#{checkpoint[:lng]},#{checkpoint[:lat]};"
      end
      @coordinateString = @coordinateString.chop
    end
  end

  def check_useragent
    user_agent = request.user_agent
    client = DeviceDetector.new(user_agent)
    
    redirect_to dashboard_mobile_path if client.device_type == 'smartphone'
  end
end
