import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "prompt",
    "generateBtn",
    "loading",
    "error",
    "preview",
    "canvas",
    "codeInput",
    "promptInput",
  ];

  connect() {
    this.generatedCode = null;
    this.currentGame = null;
  }

  async generate() {
    const prompt = this.promptTarget.value.trim();

    if (!prompt) {
      this.showError("Please enter a prompt to generate the game.");
      return;
    }

    this.hideError();
    this.showLoading();
    this.hidePreview();

    try {
      const csrfToken = document.querySelector(
        'meta[name="csrf-token"]'
      )?.content;

      const response = await fetch("/generator/preview", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({ prompt: prompt }),
      });

      const data = await response.json();

      if (data.success) {
        this.generatedCode = data.code;
        this.promptInputTarget.value = data.prompt;
        this.codeInputTarget.value = data.code;
        this.showPreview();
        this.showStartScreen();
      } else {
        this.showError(
          data.error || "Error generating game. Please try again."
        );
      }
    } catch (error) {
      console.error("Error:", error);
      this.showError("Connection error. Please try again.");
    } finally {
      this.hideLoading();
    }
  }

  regenerate() {
    this.generate();
  }

  testGame() {
    if (!this.generatedCode) return;

    try {
      // Clear previous game
      if (this.currentGame && typeof this.currentGame.end === "function") {
        this.currentGame.end();
      }

      // Load the new game
      const gameFactory = new Function(`
        ${this.generatedCode}
        return game;
      `);
      this.currentGame = gameFactory();

      if (this.currentGame && typeof this.currentGame.init === "function") {
        this.currentGame.onScoreUpdate = (score) =>
          console.log("Score:", score);
        this.currentGame.onGameEnd = (finalScore) => {
          console.log("Game ended with score:", finalScore);
          this.showGameOver(finalScore);
        };

        this.currentGame.init(this.canvasTarget);
        this.currentGame.start();
      } else {
        this.showError(
          "The generated game is not in the correct format. Please try regenerating."
        );
      }
    } catch (error) {
      console.error("Error running the game:", error);
      this.showError("Error running the game: " + error.message);
    }
  }

  showStartScreen() {
    const ctx = this.canvasTarget.getContext("2d");
    ctx.fillStyle = "#1a1a2e";
    ctx.fillRect(0, 0, 400, 400);
    ctx.fillStyle = "#e94560";
    ctx.font = "bold 24px Arial";
    ctx.textAlign = "center";
    ctx.fillText("🎮 Game Generated", 200, 180);
    ctx.fillStyle = "#ffffff";
    ctx.font = "16px Arial";
    ctx.fillText("Press TEST to play", 200, 220);
  }

  showGameOver(score) {
    const ctx = this.canvasTarget.getContext("2d");
    ctx.fillStyle = "rgba(0, 0, 0, 0.8)";
    ctx.fillRect(0, 0, 400, 400);
    ctx.fillStyle = "#e94560";
    ctx.font = "bold 32px Arial";
    ctx.textAlign = "center";
    ctx.fillText("Game Over!", 200, 170);
    ctx.fillStyle = "#ffffff";
    ctx.font = "24px Arial";
    ctx.fillText(`Score: ${score}`, 200, 220);
  }

  showLoading() {
    this.loadingTarget.classList.remove("hidden");
    this.generateBtnTarget.disabled = true;
    this.generateBtnTarget.classList.add("opacity-50");
  }

  hideLoading() {
    this.loadingTarget.classList.add("hidden");
    this.generateBtnTarget.disabled = false;
    this.generateBtnTarget.classList.remove("opacity-50");
  }

  showError(message) {
    this.errorTarget.textContent = message;
    this.errorTarget.classList.remove("hidden");
  }

  hideError() {
    this.errorTarget.classList.add("hidden");
  }

  showPreview() {
    this.previewTarget.classList.remove("hidden");
  }

  hidePreview() {
    this.previewTarget.classList.add("hidden");
  }
}
