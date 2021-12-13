class TrailsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show, :full_map ]
  skip_after_action :verify_policy_scoped, only: [:index, :show, :full_map ]

  def index
    if params[:location] && params[:location] != ""
      @trails = Trail.joins(:checkpoints).near(params[:location], 1000,
        order: :distance,
        latitude: "checkpoints.latitude",
        longitude: "checkpoints.longitude")
        .uniq { |trail| trail.id }.sort_by(&:id)
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
    @trip = Trip.new

    checkpoints_data = @trail.checkpoints_coordinates
    @markers = []
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

    authorize @trail
  end

  def full_map
    @trail = Trail.find(params[:id])
    checkpoints_data = @trail.checkpoints_coordinates

    @markers = []
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

    authorize @trail
  end
end
