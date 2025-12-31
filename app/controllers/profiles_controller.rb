class ProfilesController < ApplicationController
  def show
    if params[:username]
      @user = User.find_by!(username: params[:username])
    elsif user_signed_in?
      @user = current_user
    else
      redirect_to new_user_session_path, alert: "Please log in to view your profile"
      return
    end

    @created_games = @user.created_games.status_approved.order(created_at: :desc).limit(10)
    @recent_sessions = @user.game_sessions
                            .includes(:game)
                            .order(created_at: :desc)
                            .limit(10)
    @is_own_profile = user_signed_in? && current_user.id == @user.id
  end
end
