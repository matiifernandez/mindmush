// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import "./controllers";

// Service Worker disabled temporarily for development
// TODO: Re-enable for production
// if ("serviceWorker" in navigator) {
//   window.addEventListener("load", () => {
//     navigator.serviceWorker
//       .register("/service-worker.js")
//       .then((registration) => {
//         console.log("SW registered:", registration.scope);
//       })
//       .catch((error) => {
//         console.log("SW registration failed:", error);
//       });
//   });
// }

// Unregister any existing service workers
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.getRegistrations().then((registrations) => {
    registrations.forEach((registration) => registration.unregister());
  });
}
