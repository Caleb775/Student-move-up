## Documentation

### Overview

- **Purpose**: This Rails app manages `students` and their `notes`. It calculates each student's `total_score` and `percentage` from four skills: reading, writing, listening, speaking.
- **Primary entities**: `Student`, `Note`.
- **Web layer**: RESTful controllers `StudentsController` and `NotesController` with HTML responses (redirects after create/update/destroy).
- **Frontend**: Stimulus controllers are set up via import maps. A sample `hello` controller demonstrates usage.

### Quickstart

```bash
bin/setup
bin/dev
```

- **App URL**: http://localhost:3000 (root goes to `students#index`).
- **Health check**: `GET /up`.

### Documentation map

- **Routes**: [`docs/routes.md`](./routes.md)
- **Controllers**:
  - [`docs/controllers/StudentsController.md`](./controllers/StudentsController.md)
  - [`docs/controllers/NotesController.md`](./controllers/NotesController.md)
- **Models**:
  - [`docs/models/Student.md`](./models/Student.md)
  - [`docs/models/Note.md`](./models/Note.md)
- **Database schema**: [`docs/schema.md`](./schema.md)
- **Frontend (Stimulus)**: [`docs/javascript/Stimulus.md`](./javascript/Stimulus.md)
- **Service Worker**: [`docs/service_worker.md`](./service_worker.md)

### Conventions

- **REST**: Controllers follow Rails REST conventions. `create`/`update`/`destroy` redirect after success and re-render the form on validation errors.
- **Strong parameters**: Payloads must be nested under `student` or `note` keys.
- **JSON requests**: You can send JSON payloads with `Content-Type: application/json`; responses are HTML (302 redirects) unless you add JSON responders.

### Contributing to docs

- Place controller docs in `docs/controllers/`, model docs in `docs/models/`, and frontend docs in `docs/javascript/`.
- Keep examples runnable (e.g., `curl` with `-L` to follow redirects).
