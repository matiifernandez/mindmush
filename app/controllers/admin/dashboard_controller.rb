class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.count
    @total_games = Game.count
    @pending_games = Game.status_pending.count
    @pending_reports = Report.status_pending.count
    @recent_games = Game.includes(:creator).order(created_at: :desc).limit(5)
    @recent_reports = Report.includes(:user, :game).status_pending.order(created_at: :desc).limit(5)
  end
end
