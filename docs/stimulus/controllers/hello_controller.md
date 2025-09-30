## HelloController

File: `app/javascript/controllers/hello_controller.js`

### Public API
- Default export: a Stimulus `Controller` subclass.
- Lifecycle: `connect()` updates the element text content to "Hello World!".

### Usage
Attach the controller using `data-controller`:

```html
<div data-controller="hello"></div>
```

When connected, the element will display "Hello World!".

### Extending
You can add actions and targets for richer interactions.

```html
<div data-controller="hello" data-action="click->hello#greet" data-hello-name-value="Alice"></div>
```

```js
// hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { name: String }

  connect() {
    this.element.textContent = `Hello ${this.nameValue || "World"}!`
  }

  greet() {
    alert(`Hi ${this.nameValue || "there"}`)
  }
}
```

