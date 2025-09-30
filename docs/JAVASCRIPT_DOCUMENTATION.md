# JavaScript Documentation

## Overview

This document provides comprehensive documentation for all JavaScript components, Stimulus controllers, and frontend functionality in the Student Management System.

## Architecture

The application uses a modern Rails frontend stack with:
- **Hotwire Turbo**: For SPA-like navigation without full page reloads
- **Stimulus**: For JavaScript behavior and interactivity
- **Import Maps**: For modern ES6 module management
- **Modern Browser Support**: Leveraging latest web standards

## Main Application File

**File:** `app/javascript/application.js`

### Description

Entry point for all JavaScript functionality in the application.

### Implementation

```javascript
// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
```

### Dependencies

1. **@hotwired/turbo-rails**: Provides Turbo functionality for fast navigation
2. **controllers**: Imports all Stimulus controllers

### Features Enabled

- **Turbo Drive**: Accelerates navigation by replacing page content without full reloads
- **Turbo Frames**: Allows partial page updates
- **Turbo Streams**: Enables real-time updates via WebSocket or HTTP
- **Stimulus Controllers**: Automatic loading and registration of all controllers

---

## Stimulus Framework

### Application Controller

**File:** `app/javascript/controllers/application.js`

#### Description

Base Stimulus application configuration and setup.

#### Implementation

```javascript
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
```

#### Configuration

- **Debug Mode**: Disabled in production (`application.debug = false`)
- **Global Access**: Stimulus application available globally via `window.Stimulus`
- **Auto-start**: Application starts immediately when imported

#### Usage

This file is automatically imported and doesn't require manual interaction. It sets up the Stimulus framework for the entire application.

---

### Controller Index

**File:** `app/javascript/controllers/index.js`

#### Description

Automatic controller registration system for Stimulus.

#### Implementation

```javascript
// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
```

#### Functionality

- **Automatic Discovery**: Finds all `*_controller.js` files in the controllers directory
- **Eager Loading**: Loads all controllers immediately on application start
- **Convention-based**: Controllers are automatically registered based on filename

#### Controller Naming Convention

Controllers should follow the pattern: `[name]_controller.js`
- File: `hello_controller.js` → Controller identifier: `hello`
- File: `user_profile_controller.js` → Controller identifier: `user-profile`

---

### Hello Controller

**File:** `app/javascript/controllers/hello_controller.js`

#### Description

Example Stimulus controller demonstrating basic functionality. This is a default controller provided by Rails.

#### Implementation

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
  }
}
```

#### API Reference

##### Lifecycle Methods

**`connect()`**
- **Purpose**: Called when the controller is connected to the DOM
- **Usage**: Initialize controller state, set up event listeners, modify DOM
- **Example**: Updates element text content to "Hello World!"

#### HTML Usage

```html
<div data-controller="hello"></div>
```

**Result**: The div content will be replaced with "Hello World!" when the controller connects.

#### Customization Examples

```javascript
// Extended hello controller with more functionality
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  static values = { name: String }
  
  connect() {
    this.updateGreeting()
  }
  
  nameValueChanged() {
    this.updateGreeting()
  }
  
  updateGreeting() {
    const name = this.nameValue || "World"
    this.outputTarget.textContent = `Hello ${name}!`
  }
}
```

**HTML Usage:**
```html
<div data-controller="hello" data-hello-name-value="John">
  <span data-hello-target="output"></span>
</div>
```

---

## Hotwire Turbo Integration

### Turbo Drive

**Purpose**: Accelerates navigation by intercepting link clicks and form submissions

**Features**:
- Automatic page acceleration
- Preserves scroll position
- Maintains browser history
- Reduces server load

**Usage**: Automatically enabled, no additional code required

**Customization**:
```html
<!-- Disable Turbo for specific links -->
<a href="/external-site" data-turbo="false">External Link</a>

<!-- Force full page reload -->
<a href="/admin" data-turbo-method="get" data-turbo="false">Admin Panel</a>
```

### Turbo Frames

**Purpose**: Update specific parts of the page without full reload

**Basic Usage**:
```html
<!-- Frame definition -->
<turbo-frame id="student-details">
  <!-- Content that can be updated independently -->
</turbo-frame>

<!-- Links that target the frame -->
<a href="/students/1" data-turbo-frame="student-details">View Student</a>
```

**Advanced Usage**:
```html
<!-- Lazy-loaded frame -->
<turbo-frame id="student-notes" src="/students/1/notes" loading="lazy">
  Loading notes...
</turbo-frame>
```

### Turbo Streams

**Purpose**: Real-time page updates via WebSocket or HTTP responses

**Server Response Example**:
```ruby
# In controller
respond_to do |format|
  format.turbo_stream { render turbo_stream: turbo_stream.replace("student-#{@student.id}", @student) }
  format.html { redirect_to @student }
end
```

**HTML Template**:
```erb
<!-- app/views/students/update.turbo_stream.erb -->
<%= turbo_stream.replace "student-#{@student.id}" do %>
  <%= render @student %>
<% end %>
```

---

## Creating Custom Stimulus Controllers

### Basic Controller Template

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Define targets (elements this controller manages)
  static targets = ["input", "output", "button"]
  
  // Define values (data attributes that become properties)
  static values = { 
    url: String,
    timeout: Number,
    enabled: Boolean 
  }
  
  // Define classes (CSS classes that can be applied)
  static classes = ["loading", "error", "success"]
  
  // Lifecycle callbacks
  connect() {
    // Called when controller connects to DOM
    console.log("Controller connected")
  }
  
  disconnect() {
    // Called when controller disconnects from DOM
    console.log("Controller disconnected")
  }
  
  // Action methods (called by data-action attributes)
  handleClick(event) {
    // Handle user interactions
    event.preventDefault()
    this.performAction()
  }
  
  // Value change callbacks
  urlValueChanged(value, previousValue) {
    // Called when url value changes
    console.log(`URL changed from ${previousValue} to ${value}`)
  }
  
  // Private methods
  performAction() {
    // Internal controller logic
  }
}
```

### HTML Integration

```html
<div data-controller="custom"
     data-custom-url-value="/api/endpoint"
     data-custom-timeout-value="5000"
     data-custom-enabled-value="true"
     data-custom-loading-class="spinner"
     data-custom-error-class="text-red-500">
  
  <input data-custom-target="input" type="text">
  <button data-custom-target="button" 
          data-action="click->custom#handleClick">
    Submit
  </button>
  <div data-custom-target="output"></div>
</div>
```

---

## Student Management System Specific Examples

### Student Form Controller

**Potential Implementation** (not currently in codebase):

```javascript
// app/javascript/controllers/student_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["reading", "writing", "listening", "speaking", "total", "percentage"]
  
  connect() {
    this.calculateScores()
  }
  
  updateScores() {
    this.calculateScores()
  }
  
  calculateScores() {
    const reading = parseInt(this.readingTarget.value) || 0
    const writing = parseInt(this.writingTarget.value) || 0
    const listening = parseInt(this.listeningTarget.value) || 0
    const speaking = parseInt(this.speakingTarget.value) || 0
    
    const total = reading + writing + listening + speaking
    const percentage = (total / 40) * 100
    
    this.totalTarget.textContent = total
    this.percentageTarget.textContent = `${percentage.toFixed(1)}%`
  }
}
```

**HTML Usage**:
```html
<form data-controller="student-form">
  <input data-student-form-target="reading" 
         data-action="input->student-form#updateScores" 
         type="number" min="0" max="10">
  
  <input data-student-form-target="writing" 
         data-action="input->student-form#updateScores" 
         type="number" min="0" max="10">
  
  <input data-student-form-target="listening" 
         data-action="input->student-form#updateScores" 
         type="number" min="0" max="10">
  
  <input data-student-form-target="speaking" 
         data-action="input->student-form#updateScores" 
         type="number" min="0" max="10">
  
  <div>
    Total: <span data-student-form-target="total">0</span>/40
  </div>
  <div>
    Percentage: <span data-student-form-target="percentage">0%</span>
  </div>
</form>
```

### Note Management Controller

**Potential Implementation**:

```javascript
// app/javascript/controllers/note_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "counter"]
  static values = { maxLength: Number }
  
  connect() {
    this.updateCounter()
  }
  
  updateCounter() {
    const length = this.contentTarget.value.length
    const remaining = this.maxLengthValue - length
    
    this.counterTarget.textContent = `${remaining} characters remaining`
    this.counterTarget.classList.toggle("text-red-500", remaining < 50)
  }
  
  autoResize() {
    const textarea = this.contentTarget
    textarea.style.height = "auto"
    textarea.style.height = textarea.scrollHeight + "px"
  }
}
```

---

## Performance Considerations

### Turbo Optimization

1. **Selective Turbo Disabling**: Disable Turbo for external links and file downloads
2. **Frame Targeting**: Use Turbo Frames for partial updates instead of full page reloads
3. **Lazy Loading**: Use lazy-loaded frames for content that's not immediately needed

### Stimulus Best Practices

1. **Minimal Controllers**: Keep controllers focused on single responsibilities
2. **Efficient Selectors**: Use targets instead of manual DOM queries
3. **Event Delegation**: Leverage Stimulus's automatic event handling
4. **Memory Management**: Clean up resources in `disconnect()` callbacks

### Import Map Optimization

1. **Selective Imports**: Only import what's needed
2. **Code Splitting**: Use dynamic imports for large libraries
3. **Caching**: Leverage browser caching for static assets

---

## Browser Compatibility

### Supported Browsers

The application requires modern browsers supporting:
- WebP images
- Web Push notifications
- Badges API
- Import Maps
- CSS Nesting
- CSS `:has()` selector

### Minimum Versions

- Chrome: 88+
- Firefox: 87+
- Safari: 14+
- Edge: 88+

### Feature Detection

```javascript
// Example feature detection
if ('serviceWorker' in navigator) {
  // Progressive Web App features available
}

if (CSS.supports('selector(:has(div))')) {
  // CSS :has() selector supported
}
```

---

## Debugging and Development

### Stimulus Debugging

```javascript
// Enable debug mode in development
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = true // Enable in development
```

### Turbo Debugging

```javascript
// Listen to Turbo events for debugging
document.addEventListener("turbo:visit", (event) => {
  console.log("Turbo visit:", event.detail.url)
})

document.addEventListener("turbo:load", () => {
  console.log("Turbo page loaded")
})
```

### Common Issues and Solutions

1. **Controllers Not Loading**: Check file naming convention and import paths
2. **Turbo Conflicts**: Use `data-turbo="false"` for problematic elements
3. **Event Handling**: Ensure proper action syntax in HTML attributes
4. **Target Not Found**: Verify target names match between JS and HTML

---

## Testing JavaScript Components

### Stimulus Controller Testing

```javascript
// Example test setup (using Jest)
import { Application } from "@hotwired/stimulus"
import HelloController from "../hello_controller"

describe("HelloController", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="hello" id="test-element"></div>
    `
    
    const application = Application.start()
    application.register("hello", HelloController)
  })
  
  test("updates element text on connect", () => {
    const element = document.getElementById("test-element")
    expect(element.textContent).toBe("Hello World!")
  })
})
```

### Integration Testing

Use Rails system tests to test JavaScript functionality:

```ruby
# test/system/students_test.rb
test "student form calculates scores dynamically" do
  visit new_student_path
  
  fill_in "Reading", with: "8"
  fill_in "Writing", with: "7"
  
  # Assert dynamic calculation works
  assert_text "Total: 15/40"
  assert_text "Percentage: 37.5%"
end
```