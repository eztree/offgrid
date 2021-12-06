class TripsController < ApplicationController
  def index
    @trips = policy_scope(Trip)
    authorize @trips
  end
end
