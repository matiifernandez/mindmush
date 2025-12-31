class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:play]
  before_action :authenticate_user!, only: [:vote, :unvote]
  before_action :set_game, only: [:show, :vote, :unvote]

  def index
    @games = Game.status_approved.order(play_count: :desc).limit(20)
  end

  def show
    @leaderboard = GameSession.leaderboard_for_game(@game.id)
                              .includes(:user)
                              .limit(10)
    @user_vote = current_user&.votes&.find_by(game: @game)
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

  def vote
    value = params[:value].to_i
    unless [-1, 1].include?(value)
      redirect_to game_path(@game.slug), alert: "Invalid vote value"
      return
    end

    existing_vote = current_user.votes.find_by(game: @game)

    if existing_vote
      if existing_vote.value == value
        # Same vote, remove it
        existing_vote.destroy
        redirect_to game_path(@game.slug), notice: "Vote removed"
      else
        # Different vote, update it
        existing_vote.update(value: value)
        redirect_to game_path(@game.slug), notice: value == 1 ? "Liked!" : "Disliked!"
      end
    else
      current_user.votes.create(game: @game, value: value)
      redirect_to game_path(@game.slug), notice: value == 1 ? "Liked!" : "Disliked!"
    end
  end

  def unvote
    current_user.votes.find_by(game: @game)&.destroy
    redirect_to game_path(@game.slug), notice: "Vote removed"
  end

  private

  def set_game
    @game = Game.find_by!(slug: params[:id])
  end
end
