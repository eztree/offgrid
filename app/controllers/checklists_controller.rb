class ChecklistsController < ApplicationController
  CATEGORY_ITEMS = %w[backpack_gear kitchen_tools food water clothes_footwear navigation first_aid hygiene]
  def update
    # raise
    @checklist = Checklist.find(params[:id])
    authorize @checklist
    @checklist.checked = !@checklist.checked
    @checklist.save

    check = true
    category = @checklist.item.tag_list.intersection(CATEGORY_ITEMS)
    trip = @checklist.trip
    Item.by_tag_name(category[0], trip).each do |item_asc|
      check = false unless item_asc.checklist_status
    end
    check_all = trip.checklists.all?(&:checked)

    if @checklist.save
      render json: {
        response: 'OK',
        checklist: @checklist,
        trip: @checklist.trip,
        item: @checklist.item,
        tag_lists: @checklist.item.tag_list[1..] - ["food", "required"],
        category: category[0],
        check: check,
        checklist_count: Item.by_tag_name(category[0], trip).size,
        done_checklist_count: Item.checked_by_tag_name(category[0], trip).size,
        check_all: check_all
      }, status: 200
    end
  end

  private

  def checklist_params
    params.permit(:id)
  end
end
