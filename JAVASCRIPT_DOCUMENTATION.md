# JavaScript Documentation

## Table of Contents

1. [Overview](#overview)
2. [Stimulus Controllers](#stimulus-controllers)
3. [Application Configuration](#application-configuration)
4. [Usage Examples](#usage-examples)
5. [Creating Custom Controllers](#creating-custom-controllers)

---

## Overview

This application uses **Hotwire** for modern JavaScript interactions:

- **Turbo**: Provides SPA-like page navigation without writing JavaScript
- **Stimulus**: A modest JavaScript framework for enhancing HTML
- **Import Maps**: Native ES modules without bundling

### Architecture

```
app/javascript/
├── application.js           # Entry point
└── controllers/
    ├── application.js       # Stimulus application setup
    ├── hello_controller.js  # Example controller
    └── index.js             # Auto-generated controller loader
```

---

## Stimulus Controllers

### Application Controller

**File**: `app/javascript/controllers/application.js`

Sets up the Stimulus application and configures global settings.

```javascript
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
```

#### Configuration

| Property | Value | Description |
|----------|-------|-------------|
| `application.debug` | `false` | Disable debug logging in console |
| `window.Stimulus` | `application` | Global access to Stimulus app |

#### Usage

This is the base configuration file. You don't typically interact with it directly, but it must be imported by `application.js`.

---

### Hello Controller

**File**: `app/javascript/controllers/hello_controller.js`

An example Stimulus controller that demonstrates basic functionality.

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
  }
}
```

#### Lifecycle Callbacks

##### `connect()`

Called when the controller is connected to the DOM.

**Behavior**: Sets the element's text content to "Hello World!"

#### HTML Usage

```html
<!-- The controller automatically runs when this element appears -->
<div data-controller="hello"></div>
<!-- Will display: Hello World! -->
```

#### When to Use

This is a demo controller. You can:
- Remove it if not needed
- Use it as a template for new controllers
- Modify it for welcome messages or dynamic content

---

## Application Configuration

### Main Entry Point

**File**: `app/javascript/application.js`

```javascript
// Configure your import map in config/importmap.rb
import "@hotwired/turbo-rails"
import "controllers"
```

#### Imports

1. **@hotwired/turbo-rails**: Enables Turbo Drive, Frames, and Streams
2. **controllers**: Auto-loads all Stimulus controllers

---

## Usage Examples

### Example 1: Using the Hello Controller

```html
<!-- In any view file -->
<div data-controller="hello">
  <!-- Content will be replaced with "Hello World!" -->
</div>
```

---

### Example 2: Creating a Toggle Controller

Create a new controller to toggle visibility:

**File**: `app/javascript/controllers/toggle_controller.js`

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```

**HTML Usage**:

```html
<div data-controller="toggle">
  <button data-action="click->toggle#toggle">Toggle Content</button>
  <div data-toggle-target="content" class="hidden">
    This content can be toggled!
  </div>
</div>
```

---

### Example 3: Form Validation Controller

Create a controller for real-time form validation:

**File**: `app/javascript/controllers/validation_controller.js`

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error"]

  validate() {
    const value = this.inputTarget.value
    
    if (value.length < 3) {
      this.errorTarget.textContent = "Must be at least 3 characters"
      this.errorTarget.classList.remove("hidden")
    } else {
      this.errorTarget.textContent = ""
      this.errorTarget.classList.add("hidden")
    }
  }
}
```

**HTML Usage**:

```html
<div data-controller="validation">
  <input 
    type="text" 
    data-validation-target="input"
    data-action="input->validation#validate"
  >
  <span 
    data-validation-target="error" 
    class="text-red-500 hidden"
  ></span>
</div>
```

---

### Example 4: Score Calculator Controller

For the student application, create a controller to calculate scores in real-time:

**File**: `app/javascript/controllers/score_controller.js`

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["reading", "writing", "listening", "speaking", "total", "percentage"]

  calculate() {
    const reading = parseInt(this.readingTarget.value) || 0
    const writing = parseInt(this.writingTarget.value) || 0
    const listening = parseInt(this.listeningTarget.value) || 0
    const speaking = parseInt(this.speakingTarget.value) || 0
    
    const total = reading + writing + listening + speaking
    const percentage = (total / 40.0) * 100
    
    this.totalTarget.textContent = total
    this.percentageTarget.textContent = percentage.toFixed(1) + "%"
  }
}
```

**HTML Usage in Student Form**:

```erb
<div data-controller="score">
  <%= form.number_field :reading, 
      data: { 
        score_target: "reading",
        action: "input->score#calculate"
      } 
  %>
  
  <%= form.number_field :writing,
      data: { 
        score_target: "writing",
        action: "input->score#calculate"
      }
  %>
  
  <%= form.number_field :listening,
      data: { 
        score_target: "listening",
        action: "input->score#calculate"
      }
  %>
  
  <%= form.number_field :speaking,
      data: { 
        score_target: "speaking",
        action: "input->score#calculate"
      }
  %>
  
  <div>
    <strong>Total: <span data-score-target="total">0</span> / 40</strong>
  </div>
  
  <div>
    <strong>Percentage: <span data-score-target="percentage">0.0%</span></strong>
  </div>
</div>
```

---

## Creating Custom Controllers

### Step 1: Create Controller File

Controllers are automatically loaded from `app/javascript/controllers/`.

**Naming Convention**: 
- File: `my_feature_controller.js`
- HTML: `data-controller="my-feature"`

### Step 2: Define the Controller

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Define targets (optional)
  static targets = ["element1", "element2"]
  
  // Define values (optional)
  static values = {
    url: String,
    count: Number
  }
  
  // Lifecycle callbacks
  connect() {
    // Called when controller connects to DOM
  }
  
  disconnect() {
    // Called when controller disconnects from DOM
  }
  
  // Action methods
  myAction(event) {
    // Your logic here
  }
}
```

### Step 3: Use in HTML

```html
<div data-controller="my-feature">
  <button data-action="click->my-feature#myAction">Click Me</button>
  <div data-my-feature-target="element1">Content</div>
</div>
```

---

## Stimulus Concepts

### Controllers

JavaScript classes that handle behavior for HTML elements.

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Controller connected!")
  }
}
```

---

### Targets

DOM elements that you reference in your controller.

```javascript
static targets = ["name", "email"]

greet() {
  console.log(`Hello, ${this.nameTarget.value}!`)
}
```

```html
<div data-controller="greeting">
  <input data-greeting-target="name" type="text">
  <button data-action="click->greeting#greet">Greet</button>
</div>
```

---

### Actions

Connect DOM events to controller methods.

**Syntax**: `event->controller#method`

```html
<!-- Click event -->
<button data-action="click->counter#increment">+</button>

<!-- Submit event -->
<form data-action="submit->form#validate">

<!-- Multiple actions -->
<input data-action="input->search#query focus->search#highlight">
```

---

### Values

Pass data from HTML to JavaScript.

```javascript
static values = {
  url: String,
  refreshInterval: Number
}

connect() {
  console.log(this.urlValue)
  console.log(this.refreshIntervalValue)
}
```

```html
<div 
  data-controller="poll"
  data-poll-url-value="/api/status"
  data-poll-refresh-interval-value="5000"
>
</div>
```

---

### Classes

Reference CSS classes defined in HTML.

```javascript
static classes = ["loading", "hidden"]

show() {
  this.element.classList.remove(this.hiddenClass)
}

startLoading() {
  this.element.classList.add(this.loadingClass)
}
```

```html
<div 
  data-controller="loader"
  data-loader-loading-class="spinner"
  data-loader-hidden-class="d-none"
>
</div>
```

---

## Turbo Features

### Turbo Drive

Automatically converts page navigation to AJAX requests.

**Already enabled** - No configuration needed!

**Disable for specific links**:
```html
<a href="/page" data-turbo="false">Regular Link</a>
```

---

### Turbo Frames

Load parts of the page independently.

```erb
<%= turbo_frame_tag "student_#{@student.id}" do %>
  <div class="student-card">
    <%= render @student %>
  </div>
<% end %>
```

---

### Turbo Streams

Update multiple parts of the page from a single request.

**Controller**:
```ruby
def create
  @student = Student.new(student_params)
  if @student.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @student }
    end
  end
end
```

**View** (`create.turbo_stream.erb`):
```erb
<%= turbo_stream.prepend "students", @student %>
<%= turbo_stream.update "flash", partial: "shared/notice" %>
```

---

## Import Maps

### Configuration

**File**: `config/importmap.rb`

```ruby
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
```

### Adding New JavaScript Libraries

```bash
# Add a library via importmap
bin/importmap pin chart.js
```

Then use in JavaScript:
```javascript
import Chart from "chart.js"
```

---

## Best Practices

### 1. Keep Controllers Focused

Each controller should handle one specific behavior.

❌ **Bad**:
```javascript
// One controller doing everything
export default class extends Controller {
  toggleMenu() { }
  validateForm() { }
  calculateScore() { }
  fetchData() { }
}
```

✅ **Good**:
```javascript
// Separate controllers for each concern
// menu_controller.js
export default class extends Controller {
  toggle() { }
}

// form_controller.js
export default class extends Controller {
  validate() { }
}
```

---

### 2. Use Data Attributes

Store configuration in HTML, not JavaScript.

❌ **Bad**:
```javascript
const API_URL = "https://api.example.com"
```

✅ **Good**:
```javascript
static values = { apiUrl: String }

fetch() {
  return fetch(this.apiUrlValue)
}
```

```html
<div data-controller="api" data-api-url-value="/students.json">
```

---

### 3. Clean Up Resources

Remove event listeners and timers when controllers disconnect.

```javascript
connect() {
  this.interval = setInterval(() => this.refresh(), 5000)
}

disconnect() {
  clearInterval(this.interval)
}
```

---

### 4. Progressive Enhancement

Ensure functionality works without JavaScript.

```html
<!-- Form works with or without JavaScript -->
<form action="/students" method="post" data-controller="form-validator">
  <%= form_with model: @student %>
</form>
```

---

## Debugging

### Enable Stimulus Debug Mode

**File**: `app/javascript/controllers/application.js`

```javascript
application.debug = true  // Enable debug logging
```

This will log:
- Controller lifecycle events
- Action invocations
- Target resolutions

---

### Browser Console

```javascript
// Access Stimulus from console
Stimulus.controllers

// Get controller for an element
const element = document.querySelector('[data-controller="hello"]')
const controller = Stimulus.getControllerForElementAndIdentifier(element, "hello")
```

---

## Testing Stimulus Controllers

### Using Jest

**Install dependencies**:
```bash
npm install --save-dev jest @testing-library/dom
```

**Test example**:
```javascript
import { Application } from "@hotwired/stimulus"
import HelloController from "../hello_controller"

describe("HelloController", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="hello"></div>
    `
    
    const application = Application.start()
    application.register("hello", HelloController)
  })

  it("displays hello world", () => {
    const element = document.querySelector('[data-controller="hello"]')
    expect(element.textContent).toBe("Hello World!")
  })
})
```

---

## Resources

### Official Documentation

- **Stimulus**: https://stimulus.hotwired.dev
- **Turbo**: https://turbo.hotwired.dev
- **Hotwire**: https://hotwired.dev

### Video Tutorials

- Hotwire Handbook: https://www.hotwire.dev/handbook
- GoRails Hotwire Series: https://gorails.com/series/hotwire-rails

### Community

- Hotwire Discussion: https://discuss.hotwired.dev
- Stack Overflow: [hotwire] tag

---

## Summary

This application uses Hotwire (Turbo + Stimulus) for a modern, fast user experience:

1. **Turbo Drive**: Automatic AJAX navigation
2. **Stimulus Controllers**: Enhance HTML with JavaScript
3. **Import Maps**: No build step required
4. **Progressive Enhancement**: Works without JavaScript

Start by exploring the example `hello_controller.js` and create your own controllers as needed!