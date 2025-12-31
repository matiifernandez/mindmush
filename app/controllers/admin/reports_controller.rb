class Admin::ReportsController < Admin::BaseController
  before_action :set_report, only: [:update, :dismiss, :action_taken]

  def index
    @reports = Report.includes(:user, :game).order(created_at: :desc)
    @reports = @reports.where(status: params[:status]) if params[:status].present?
    @reports = @reports.page(params[:page]).per(20) if @reports.respond_to?(:page)
  end

  def update
    if @report.update(report_params)
      redirect_to admin_reports_path, notice: "Report updated."
    else
      redirect_to admin_reports_path, alert: "Failed to update report."
    end
  end

  def dismiss
    @report.update(status: :dismissed, reviewed_by: current_user, reviewed_at: Time.current)
    redirect_to admin_reports_path, notice: "Report dismissed."
  end

  def action_taken
    @report.update(status: :actioned, reviewed_by: current_user, reviewed_at: Time.current)
    # Optionally archive the game if action is taken
    @report.game.status_archived! if params[:archive_game] == "1"
    redirect_to admin_reports_path, notice: "Report marked as actioned."
  end

  private

  def set_report
    @report = Report.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:status)
  end
end
