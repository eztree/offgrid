class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @trails = Trail.all
    redirect_to dashboard_path if user_signed_in?
  end

  def dashboard
    @trails = Trail.all
    @trips = current_user.trips
    @current_trip = @trips.first
    @trip_dates = @current_trip.checkpoints.map { |point| point.trip_date(@current_trip) } unless @current_trip.nil?
  end
end
