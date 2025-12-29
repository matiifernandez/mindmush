class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:play]

  def index
    @games = Game.status_approved.order(play_count: :desc).limit(20)
  end

  def show
    @game = Game.find_by!(slug: params[:id])
  end

  def random
    @game = Game.status_approved.order("RANDOM()").first

    if @game
      redirect_to game_path(@game.slug)
    else
      redirect_to games_path, alert: "No games available."
    end
  end

  def play
    @game = Game.find(params[:id])

    @session = GameSession.new(
      game: @game,
      user: current_user,
      score: params[:score].to_i,
      duration_played: params[:duration].to_i,
      completed: params[:completed] == true || params[:completed] == "true"
    )

    if @session.save
      # Update user stats if logged in
      if current_user
        current_user.increment!(:games_played)
        current_user.increment!(:total_score, @session.score)
      end

      render json: {
        success: true,
        score: @session.score,
        message: "Score saved successfully."
      }
    else
      render json: {
        success: false,
        errors: @session.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end
