## Service worker

The project includes a commented example service worker at `app/views/pwa/service-worker.js` for Web Push notifications.

### Enabling notifications (example)

Uncomment and tailor the listeners:

```javascript
self.addEventListener("push", async (event) => {
  const { title, options } = await event.data.json()
  event.waitUntil(self.registration.showNotification(title, options))
})

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

### Registering the worker

- Serve the worker at a stable URL (e.g., `/service-worker.js`).
- Register from the browser:

```javascript
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/service-worker.js")
}
```

### Notes

- Make sure to set appropriate cache and security headers for service worker files.
