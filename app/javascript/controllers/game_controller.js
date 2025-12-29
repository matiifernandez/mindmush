import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["canvas", "score"];
  static values = {
    code: String,
    id: Number,
  };

  connect() {
    console.log("Game controller connected!");
    this.ctx = this.canvasTarget.getContext("2d");
    this.currentGame = null;
    this.isRunning = false;
    this.score = 0;

    // Show the initial screen
    this.showStartScreen();
  }

  showStartScreen() {
    this.ctx.fillStyle = "#1a1a2e";
    this.ctx.fillRect(0, 0, 400, 400);
    this.ctx.fillStyle = "#e94560";
    this.ctx.font = "bold 24px Arial";
    this.ctx.textAlign = "center";
    this.ctx.fillText("🧠 MindMush", 200, 180);
    this.ctx.fillStyle = "#ffffff";
    this.ctx.font = "16px Arial";
    this.ctx.fillText("Press PLAY to start", 200, 220);
  }

  start() {
    if (this.isRunning) return;

    this.isRunning = true;
    this.score = 0;
    this.updateScore(0);

    try {
      // Create the game from the saved code
      this.currentGame = this.loadGame(this.codeValue);

      if (this.currentGame && typeof this.currentGame.init === "function") {
        // Callbacks to communicate with the controller
        this.currentGame.onScoreUpdate = (score) => this.updateScore(score);
        this.currentGame.onGameEnd = (finalScore) => this.endGame(finalScore);

        // Start the game
        this.currentGame.init(this.canvasTarget);
        this.currentGame.start();
      } else {
        this.showError("Error: The game format is incorrect");
      }
    } catch (error) {
      console.error("Error loading game:", error);
      this.showError("Error loading the game");
    }
  }

  loadGame(code) {
    // Create a function that returns the game object
    // We use Function instead of eval for relative security
    try {
      const gameFactory = new Function(`
        ${code}
        return game;
      `);
      return gameFactory();
    } catch (error) {
      console.error("Error parsing game code:", error);
      return null;
    }
  }

  restart() {
    this.stop();
    this.start();
  }

  stop() {
    this.isRunning = false;
    if (this.currentGame && typeof this.currentGame.end === "function") {
      this.currentGame.end();
    }
    this.currentGame = null;
  }

  updateScore(score) {
    this.score = score;
    this.scoreTarget.textContent = score;
  }

  endGame(finalScore) {
    this.isRunning = false;
    this.updateScore(finalScore);

    // Show end screen
    this.ctx.fillStyle = "rgba(0, 0, 0, 0.8)";
    this.ctx.fillRect(0, 0, 400, 400);
    this.ctx.fillStyle = "#e94560";
    this.ctx.font = "bold 32px Arial";
    this.ctx.textAlign = "center";
    this.ctx.fillText("¡Fin del juego!", 200, 170);
    this.ctx.fillStyle = "#ffffff";
    this.ctx.font = "24px Arial";
    this.ctx.fillText(`Score: ${finalScore}`, 200, 220);
    this.ctx.font = "16px Arial";
    this.ctx.fillText("Presiona REINICIAR para jugar de nuevo", 200, 270);

    // TODO: Save score to backend
    this.saveScore(finalScore);
  }

  showError(message) {
    this.ctx.fillStyle = "#1a1a2e";
    this.ctx.fillRect(0, 0, 400, 400);
    this.ctx.fillStyle = "#ff0000";
    this.ctx.font = "16px Arial";
    this.ctx.textAlign = "center";
    this.ctx.fillText(message, 200, 200);
    this.isRunning = false;
  }

  async saveScore(score) {
    // For now, just log, later we implement the endpoint
    console.log(`Score to save: ${score} for game ${this.idValue}`);
  }

  disconnect() {
    this.stop();
  }
}
