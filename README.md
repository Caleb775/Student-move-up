# README

## Documentation

Comprehensive docs are available in `docs/`:

- **Index**: `docs/index.md`
- **Stimulus**: `docs/stimulus/overview.md`
- **Hello controller**: `docs/stimulus/controllers/hello_controller.md`
- **JavaScript app entry**: `docs/javascript/app_entry.md`
- **PWA service worker**: `docs/pwa/service_worker.md`

## Quick start

1. Ensure import maps are configured in `config/importmap.rb`.
2. Include `<%= javascript_importmap_tags %>` in your layout.
3. Use `data-controller` attributes to attach Stimulus controllers.
4. Optionally register the service worker for PWA features.
