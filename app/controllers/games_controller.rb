class GamesController < ApplicationController
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
end
