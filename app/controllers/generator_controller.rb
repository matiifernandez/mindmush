class GeneratorController < ApplicationController
  before_action :authenticate_user!
  def new
    # Form to create a new game
  end

  def create
    game_params = params[:game] || {}
    @game = Game.new(
      title: game_params[:title],
      description: game_params[:description],
      code: params[:code],
      prompt_used: params[:prompt],
      game_type: "ai_generated",
      difficulty: game_params[:difficulty] || 2,
      duration: game_params[:duration] || 30,
      status: "approved",
      creator: current_user
    )

    if @game.save
      current_user.increment!(:games_created)
      redirect_to game_path(@game.slug), notice: "Game created successfully!"
    else
      flash[:alert] = @game.errors.full_messages.join(", ")
      redirect_to generator_path
    end
  end

  def preview
    @prompt = params[:prompt]

    if @prompt.blank?
      render json: { error: "Prompt cannot be blank" }, status: :unprocessable_entity
      return
    end

    begin
      generator = GameGenerator.new
      @code = generator.generate(@prompt)

      render json: {
        success: true,
        code: @code,
        prompt: @prompt
      }
    rescue => e
      render json: { error: "Generation failed: #{e.message}" }, status: :unprocessable_entity
    end
  end
end
