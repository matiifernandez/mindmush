import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    autoDismiss: { type: Boolean, default: true },
    delay: { type: Number, default: 5000 },
  };

  connect() {
    // Animate in
    this.element.classList.add("animate-slide-in");

    if (this.autoDismissValue) {
      this.timeout = setTimeout(() => this.dismiss(), this.delayValue);
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }

  dismiss() {
    this.element.classList.add("animate-slide-out");
    this.element.addEventListener("animationend", () => {
      this.element.remove();
    });
  }
}
