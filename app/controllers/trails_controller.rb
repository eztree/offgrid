class TrailsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  skip_after_action :verify_policy_scoped, only: [:index]

  def index
    @trails = Trail.all
    @markers = []
  end

  def show
    @trail = Trail.find(params[:id])
    @trip = Trip.new
  end
end
