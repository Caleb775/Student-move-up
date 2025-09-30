/**
 * Application JavaScript Entry Point
 * 
 * This is the main entry point for all JavaScript in the application.
 * It imports and initializes Hotwire (Turbo + Stimulus) for modern SPA-like interactions.
 * 
 * @module application
 * 
 * @description
 * The application uses:
 * - Turbo: For fast page navigation and partial page updates without writing JavaScript
 * - Stimulus: For adding JavaScript behavior to HTML elements
 * - Import Maps: For managing JavaScript dependencies without a build step
 * 
 * @see {@link https://github.com/rails/importmap-rails} for import map configuration
 * @see {@link config/importmap.rb} for module definitions
 */

/**
 * Import Turbo Rails
 * 
 * Provides:
 * - Turbo Drive: Intercepts link clicks and form submissions for AJAX navigation
 * - Turbo Frames: Load independent parts of the page
 * - Turbo Streams: Update multiple parts of the page from a single request
 * 
 * @see {@link https://turbo.hotwired.dev}
 */
import "@hotwired/turbo-rails"

/**
 * Import all Stimulus controllers
 * 
 * Automatically loads all controllers from app/javascript/controllers/
 * Controllers are registered with Stimulus and made available to the application
 * 
 * Usage in HTML: data-controller="controller-name"
 * 
 * @see {@link https://stimulus.hotwired.dev}
 */
import "controllers"
