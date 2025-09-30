## Project Documentation

This project uses Stimulus and Turbo via import maps. The public surface consists of the JavaScript application entrypoint, the Stimulus application singleton, auto-registered controllers, and an optional PWA service worker.

### Table of contents
- **Stimulus overview**: `docs/stimulus/overview.md`
- **Hello controller**: `docs/stimulus/controllers/hello_controller.md`
- **JavaScript app entry**: `docs/javascript/app_entry.md`
- **PWA service worker**: `docs/pwa/service_worker.md`

### Quick start
1. Ensure import maps load Turbo and Stimulus controllers in your layout.
2. Use `data-controller` attributes in HTML to attach Stimulus controllers.
3. Optionally register a service worker for Web Push and offline capabilities.

