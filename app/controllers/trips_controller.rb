class TripsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  def index
    @trips = policy_scope(Trip)
    authorize @trips
  end

  def new
    @trail = Trail.find(params['trail'])
    @trip = Trip.new

    authorize @trip
    authorize @trail
  end
end
