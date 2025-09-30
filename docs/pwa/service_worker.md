## PWA Service Worker

File: `app/views/pwa/service-worker.js`

This file contains commented examples for handling Web Push and notification click events. Uncomment and adapt the listeners to enable functionality.

### Enabling push notifications

```js
self.addEventListener("push", async (event) => {
  const { title, options } = await event.data.json()
  event.waitUntil(self.registration.showNotification(title, options))
})
```

### Handling notification clicks

```js
self.addEventListener("notificationclick", function(event) {
  event.notification.close()
  event.waitUntil(
    clients.matchAll({ type: "window" }).then((clientList) => {
      for (let i = 0; i < clientList.length; i++) {
        let client = clientList[i]
        let clientPath = (new URL(client.url)).pathname

        if (clientPath == event.notification.data.path && "focus" in client) {
          return client.focus()
        }
      }

      if (clients.openWindow) {
        return clients.openWindow(event.notification.data.path)
      }
    })
  )
})
```

### Registering the service worker
Add this to your layout to register the service worker (served as `/service-worker.js`):

```html
<script>
  if ("serviceWorker" in navigator) {
    window.addEventListener("load", () => {
      navigator.serviceWorker.register("/service-worker.js")
    })
  }
  </script>
```

Ensure headers for `service-worker.js` allow proper scope and caching as needed.

