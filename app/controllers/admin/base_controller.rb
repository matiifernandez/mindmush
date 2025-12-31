class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    unless user_signed_in? && current_user.admin?
      flash[:alert] = "You don't have permission to access this area."
      redirect_to root_path
    end
  end
end
