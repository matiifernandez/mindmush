import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    message: { type: String, default: "Are you sure?" },
  };

  connect() {
    this.element.addEventListener("click", this.handleClick.bind(this));
  }

  disconnect() {
    this.element.removeEventListener("click", this.handleClick.bind(this));
    this.removeModal();
  }

  handleClick(event) {
    event.preventDefault();
    event.stopPropagation();
    this.showModal();
  }

  showModal() {
    // Create modal backdrop
    this.backdrop = document.createElement("div");
    this.backdrop.className =
      "fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4";
    this.backdrop.innerHTML = `
      <div class="bg-slate-800 rounded-2xl border border-slate-700 p-6 max-w-md w-full shadow-2xl animate-scale-in">
        <div class="text-center mb-6">
          <div class="w-16 h-16 mx-auto mb-4 rounded-full bg-rose-500/20 flex items-center justify-center">
            <svg class="w-8 h-8 text-rose-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
            </svg>
          </div>
          <h3 class="text-xl font-semibold text-white mb-2">Confirm Action</h3>
          <p class="text-slate-400">${this.messageValue}</p>
        </div>
        <div class="flex gap-3">
          <button type="button" data-action="cancel" class="flex-1 px-4 py-2.5 bg-slate-700 text-slate-300 font-medium rounded-lg hover:bg-slate-600 transition cursor-pointer">
            Cancel
          </button>
          <button type="button" data-action="confirm" class="flex-1 px-4 py-2.5 bg-rose-500 text-white font-medium rounded-lg hover:bg-rose-600 transition cursor-pointer">
            Confirm
          </button>
        </div>
      </div>
    `;

    // Add event listeners
    this.backdrop.querySelector('[data-action="cancel"]').addEventListener("click", () => this.cancel());
    this.backdrop.querySelector('[data-action="confirm"]').addEventListener("click", () => this.confirm());
    this.backdrop.addEventListener("click", (e) => {
      if (e.target === this.backdrop) this.cancel();
    });

    // Handle escape key
    this.escapeHandler = (e) => {
      if (e.key === "Escape") this.cancel();
    };
    document.addEventListener("keydown", this.escapeHandler);

    document.body.appendChild(this.backdrop);
    document.body.style.overflow = "hidden";
  }

  removeModal() {
    if (this.backdrop) {
      document.body.removeChild(this.backdrop);
      document.body.style.overflow = "";
      this.backdrop = null;
    }
    if (this.escapeHandler) {
      document.removeEventListener("keydown", this.escapeHandler);
    }
  }

  cancel() {
    this.removeModal();
  }

  confirm() {
    this.removeModal();
    // Find and submit the form
    const form = this.element.closest("form") || this.element.querySelector("form");
    if (form) {
      form.submit();
    }
  }
}
