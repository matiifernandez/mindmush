class Admin::GamesController < Admin::BaseController
  before_action :set_game, only: [:update, :destroy, :approve, :reject]

  def index
    @games = Game.includes(:creator).order(created_at: :desc)
    @games = @games.where(status: params[:status]) if params[:status].present?
    @games = @games.page(params[:page]).per(20) if @games.respond_to?(:page)
  end

  def update
    if @game.update(game_params)
      redirect_to admin_games_path, notice: "Game updated successfully."
    else
      redirect_to admin_games_path, alert: "Failed to update game."
    end
  end

  def destroy
    @game.destroy
    redirect_to admin_games_path, notice: "Game deleted successfully."
  end

  def approve
    @game.status_approved!
    redirect_to admin_games_path, notice: "Game '#{@game.title}' has been approved."
  end

  def reject
    @game.status_rejected!
    redirect_to admin_games_path, notice: "Game '#{@game.title}' has been rejected."
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:title, :description, :status, :is_featured, :difficulty)
  end
end
