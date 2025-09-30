/**
 * Hello Controller
 * 
 * A simple example Stimulus controller that demonstrates basic functionality.
 * This controller sets the text content of its element when connected to the DOM.
 * 
 * @example
 * <!-- HTML Usage -->
 * <div data-controller="hello"></div>
 * <!-- Will display: Hello World! -->
 * 
 * @example
 * <!-- Custom element -->
 * <span data-controller="hello" class="greeting"></span>
 * 
 * @extends Controller
 */
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  /**
   * Lifecycle callback: Called when the controller is connected to the DOM
   * 
   * Sets the element's text content to "Hello World!"
   * This runs automatically when the element with data-controller="hello" appears in the DOM.
   * 
   * @returns {void}
   */
  connect() {
    this.element.textContent = "Hello World!"
  }
}
