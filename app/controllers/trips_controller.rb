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
    # condition to check if export button was pressed
    @trip = Trip.find(params[:id])

    if params[:format].present?
        export_pdf(@trip)
    else
      @trip_days = (@trip.end_date - @trip.start_date).to_i + 1
      @trip_dates = @trip.checkpoints.map { |point| point.trip_date(@trip) }
      @category_items = %w[backpack_gear kitchen_tools food water clothes_footwear navigation first_aid hygiene]

      @markers = []
      @elevation_arr = []
      @checklists = @trip.checklists

      checkpoints_data = @trip.trail.checkpoints_coordinates

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

      checkpoints = @trip.trail.checkpoints
      checkpoints.each_with_index do |checkpoint, index|
        if index === 0
          @elevation_arr << ["start", checkpoint.elevation]
        elsif index === checkpoints.count - 1
          @elevation_arr << ["end", checkpoint.elevation]
        else
          @elevation_arr << ["checkpoint#{index}", checkpoint.elevation]
        end
        max = @elevation_arr.max { |a, b| a[1] <=> b[1] }
        @max_no = (max[1] + 50).to_s
        min = @elevation_arr.min { |a, b| a[1] <=> b[1] }
        @min_no = (min[1] - 10 ).to_s
      end
    end
    authorize @trip
  end

  def update
    @trip = Trip.find(params[:id])
    @trip.update(last_photo: Date.today)
    @trip.update!(trip_params)
    authorize @trip

    redirect_to user_trip_path(current_user, @trip)
  end

  private

  def create_tmp_user
    User.where(email: "placeholder@email.com").first
  end

  def trip_params
    params.require(:trip).permit(:photo)
  end

  def export_pdf(trip)
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string(
        template: 'trips/trip.html.erb',
        layout: 'layouts/pdf.html.erb')
      )
    send_data(pdf,
      filename: "#{trip.trail.name}_#{trip.start_date}.pdf",
      type: 'application/pdf',
      disposition: 'attachment')
  end
end
