## JavaScript Application Entry

File: `app/javascript/application.js`

This module imports Turbo and the Stimulus controllers entry, ensuring both are initialized.

### Behavior
- Imports `@hotwired/turbo-rails` to enable Turbo Drive/Frames/Streams.
- Imports `controllers` which starts the Stimulus app and auto-registers controllers.

```js
import "@hotwired/turbo-rails"
import "controllers"
```

Include this module in your import map and your layout to activate Turbo and Stimulus.

### Example layout snippet

```erb
<%= javascript_importmap_tags %>
```

