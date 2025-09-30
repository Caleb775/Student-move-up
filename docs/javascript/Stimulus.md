## Stimulus setup and example

### Bootstrapping

- `app/javascript/application.js` imports Turbo and the controllers index.
- `app/javascript/controllers/application.js` starts the Stimulus application.
- `app/javascript/controllers/index.js` eagerly loads controllers from `controllers/**/*_controller`.

### Example controller: `hello`

File: `app/javascript/controllers/hello_controller.js`

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
  }
}
```

### Usage in HTML

```html
<div data-controller="hello"></div>
```

When the element connects, its text will become "Hello World!".

### Troubleshooting

- Ensure `import "controllers"` is present in `app/javascript/application.js`.
- If controllers do not load, check that files end with `_controller.js` and that import map entries exist.
