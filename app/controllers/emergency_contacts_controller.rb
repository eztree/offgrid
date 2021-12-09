class EmergencyContactsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def create
    # code
  end

  def update
    # code
  end

  private

  def emergency_contact_params
    params.require(:emergency_contact)
          .permit(:name, :email, :phone_no)
  end
end
