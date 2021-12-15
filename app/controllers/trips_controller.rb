class TripsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create, :checklist_mobile ]

  # before_action :check_useragent, only: [ :show ]

  CATEGORY_ITEMS = %w[backpack_gear kitchen_tools food water clothes_footwear navigation first_aid hygiene]
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
    @trip_days = (@trip.end_date - @trip.start_date).to_i + 1
    @trip_dates = @trip.checkpoints.map { |point| point.trip_date(@trip) }
    @category_items = CATEGORY_ITEMS
    @checklists = @trip.checklists
    @breakfast_arr = populate_meal_arr(@trip.items.tagged_with("breakfast"))
    @meal_arr = populate_meal_arr(@trip.items.tagged_with("lunch_dinner"))
    # FOR MAPBOX
    if params[:format].present?
      export_pdf(@trip)
    else
      check_useragent()
      @trip_days = (@trip.end_date - @trip.start_date).to_i + 1
      @trip_dates = @trip.checkpoints.map { |point| point.trip_date(@trip) }

      @markers = []
      @elevation_arr = []
      @checkpoint_name_arr = []
      checkpoints_data = @trip.trail.checkpoints_coordinates

      @coordinate_string = ""
      checkpoints_data.each do |checkpoint|
        @markers << {
          lat: checkpoint[:lat],
          lng: checkpoint[:lng],
          info_window: render_to_string(partial: "trails/checkpoint_info_window", locals: { checkpoint: checkpoint })
        }
        @coordinate_string += "#{checkpoint[:lng]},#{checkpoint[:lat]};"
      end
      @coordinate_string = @coordinate_string.chop
      # END

      # FOR CHARTKICK
      checkpoints = @trip.trail.checkpoints
      checkpoints.each_with_index do |checkpoint, index|
        @checkpoint_name_arr << checkpoint.name
        if index === 0
          @elevation_arr << ["start", checkpoint.elevation]
        elsif index === checkpoints.count - 1
          @elevation_arr << ["end", checkpoint.elevation]
        else
          @elevation_arr << ["checkpoint#{index}", checkpoint.elevation]
        end
      end
      max = @elevation_arr.max { |a, b| a[1] <=> b[1] }
      @max_no = (max[1] + 50).to_s
      min = @elevation_arr.min { |a, b| a[1] <=> b[1] }
      @min_no = (min[1] - 10 ).to_s
    end
    # END
    @check_category_hash = check_item_category(@trip)
    authorize @trip
  end

  def update
    @trip = Trip.find(params[:id])
    if params[:upload].present?
      @trip.update(last_seen_photo: Date.today)
      redirect_to request.referer
      authorize @trip
      return
    end

    @trip.update(last_photo: Date.today)
    @trip.update!(trip_params)
    authorize @trip

    redirect_to user_trip_path(current_user, @trip)
  end

  def checklist_mobile
    @user = current_user
    @trip = Trip.find(params[:id])
    @trip_days = (@trip.end_date - @trip.start_date).to_i + 1
    @trip_dates = @trip.checkpoints.map { |point| point.trip_date(@trip) }
    @category_items = %w[backpack_gear kitchen_tools food water clothes_footwear navigation first_aid hygiene]

    @checklists = @trip.checklists
    @breakfast_arr = populate_meal_arr(@trip.items.tagged_with("breakfast"))
    @meal_arr = populate_meal_arr(@trip.items.tagged_with("lunch_dinner"))

    @check_category_hash = check_item_category(@trip)

    authorize @trip
  end

  def check_useragent
    user_agent = request.user_agent
    client = DeviceDetector.new(user_agent)

    redirect_to checklist_mobile_path if client.device_type == 'smartphone'
  end

  def update_checklists
    # initialize variables
    trip = Trip.find(params[:id])
    check = params[:check] === "true"
    category = params[:category]

    # uncheck or check all items
    trip.checklists.each do |checklist|
      if checklist.item.tag_list.include?(category)
        # raise
        if check
          checklist.checked = false
        else
          checklist.checked = true
        end
      checklist.save
      end
    end
    # check if all trips are checked
    check_all = trip.checklists.all?(&:checked)

    # json response to checklist_controller.js
    render json: {
      response: 'OK',
      checklists: Item.by_tag_name(category, trip),
      trip: trip,
      check: !check,
      category: category,
      # item: @checklist.item,
      # tag_lists: @checklist.item.tag_list[1..] - ["food", "required"],
      check_all: check_all
    }, status: 200
    authorize trip
  end

  private

  def check_item_category(trip)
    check_category_hash = {}
    CATEGORY_ITEMS.each do |category_item|
      check = true
      Item.by_tag_name(category_item, trip).each do |item_asc|
        check = false unless item_asc.checklist_status
      end
      check_category_hash[category_item.to_sym] = check
    end
    check_category_hash
  end

  def populate_meal_arr(array)
    arr = []
    array.each do |item|
      arr << item.name
    end
    arr
  end

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
        layout: 'layouts/pdf.html.erb'
      )
    )
    send_data(
      pdf,
      filename: "#{trip.trail.name}_#{trip.start_date}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
    )
  end
end
