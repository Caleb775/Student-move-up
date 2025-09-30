## Stimulus integration

The Stimulus application is initialized in `app/javascript/controllers/application.js` and exported as `application` for optional customization.

### Public API
- **`application` (Stimulus Application)**: exported singleton used to configure debugging or manually register controllers.

### Initialization
The application starts automatically on import. Debugging is disabled by default.

Example: enabling debug mode and registering a controller manually.

```js
import { application } from "controllers/application"
import HelloController from "controllers/hello_controller"

application.debug = true
application.register("hello", HelloController)
```

### Using in HTML
Once registered or auto-registered, attach controllers with `data-controller`:

```html
<div data-controller="hello">Hello placeholder</div>
```

Turbo will progressively enhance navigation, and Stimulus will connect the controller to this element on page load or when added to the DOM.

### Auto-registration
Controllers are eagerly loaded via `app/javascript/controllers/index.js` using `@hotwired/stimulus-loading`:

```js
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
```

Place controller files matching `*_controller.js` inside `app/javascript/controllers/` and they will be auto-registered.

