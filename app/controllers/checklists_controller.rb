class ChecklistsController < ApplicationController
  def update
    # raise
    @checklist = Checklist.find(params[:id])
    @checklist.checked = !@checklist.checked
    # @checklist.update!(checklist_params)
    @checklist.save
    respond_to do |format|
      # format.json { redirect_to trips_path }
      # format.html { "respondeeed"}
      format.text { "response" }
    end

    authorize @checklist
  end

  private

  def checklist_params
    params.permit(:id)
  end
end
