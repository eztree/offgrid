class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @trails = Trail.all
    redirect_to pages_path if user_signed_in?
  end

  def dashboard
    @trails = Trail.all
    @trips = current_user.trips
    @current_trip = @trips.first
  end
end
