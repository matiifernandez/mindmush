class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:play]
  before_action :authenticate_user!, only: [:vote, :unvote, :report]
  before_action :set_game, only: [:show, :vote, :unvote, :report]

  def index
    @games = Game.status_approved.order(play_count: :desc).limit(20)
  end

  def show
    @leaderboard = GameSession.leaderboard_for_game(@game.id)
                              .includes(:user)
                              .limit(10)
    @user_vote = current_user&.votes&.find_by(game: @game)
    @user_report = current_user&.reports&.find_by(game: @game)
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

  def report
    reason = params[:reason]

    unless Report.reasons.keys.include?(reason)
      redirect_to game_path(@game.slug), alert: "Invalid report reason"
      return
    end

    existing_report = current_user.reports.find_by(game: @game)

    if existing_report
      redirect_to game_path(@game.slug), alert: "You have already reported this game"
    else
      report = current_user.reports.build(
        game: @game,
        reason: reason,
        description: params[:description]
      )

      if report.save
        redirect_to game_path(@game.slug), notice: "Report submitted. Thank you for helping keep MindMush safe!"
      else
        redirect_to game_path(@game.slug), alert: report.errors.full_messages.join(", ")
      end
    end
  end

  private

  def set_game
    @game = Game.find_by!(slug: params[:id])
  end
end
