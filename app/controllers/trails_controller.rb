class TrailsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  skip_after_action :verify_policy_scoped, only: [:index]

  def index
    @trails = Trail.all
    @markers = []
    @trails.each do |trail|
      @markers << {
        lat: trail.start_lat,
        lng: trail.start_lon
      }
    end
    @trip = Trip.new
  end

  def show
    @trail = Trail.find(params[:id])
  end
end
