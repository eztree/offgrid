class TrailsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  skip_after_action :verify_policy_scoped, only: [:index]

  def index
    if params[:location] && params[:location] != ""
      @trails = Trail.joins(:checkpoints).near(params[:location], 1000,
        order: :distance,
        latitude: "checkpoints.latitude",
        longitude: "checkpoints.longitude")
        .uniq { |trail| trail.id }
    else
      @trails = Trail.includes(:checkpoints)
    end

    @markers = []
    @trails.each do |trail|
      coordinates = trail.coordinates
      @markers << {
        lat: coordinates[:lat],
        lng: coordinates[:lng],
        info_window: render_to_string(partial: "info_window", locals: { trail: trail })
      }
    end
    @trip = Trip.new
  end

  def show
    @trail = Trail.find(params[:id])
    authorize @trail
    @trip = Trip.new
  end
end
