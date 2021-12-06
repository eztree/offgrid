class TrailsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]

  def index
    authorize @trail
  end
end
