/**
 * Stimulus Application Configuration
 * 
 * This file sets up the Stimulus application instance and configures global settings.
 * All Stimulus controllers in the application inherit from this configuration.
 * 
 * @module controllers/application
 */

import { Application } from "@hotwired/stimulus"

/**
 * Initialize and start the Stimulus application
 * 
 * @type {Application}
 */
const application = Application.start()

// Configure Stimulus development experience
/**
 * Debug mode - set to true to enable verbose console logging
 * Shows controller lifecycle events, actions, and targets
 * 
 * @type {boolean}
 */
application.debug = false

/**
 * Expose Stimulus application globally for debugging and testing
 * Access via browser console: window.Stimulus
 * 
 * @type {Application}
 * @global
 */
window.Stimulus   = application

export { application }
