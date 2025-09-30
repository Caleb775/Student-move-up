## Routes

### Summary

| Method | Path | Controller#Action | Notes |
|---|---|---|---|
| GET | / | students#index | Root |
| GET | /up | rails/health#show | Health check |
| GET | /students | students#index | List students (sorted by `percentage` desc) |
| GET | /students/new | students#new | New student form |
| POST | /students | students#create | Create student |
| GET | /students/:id | students#show | Show student |
| GET | /students/:id/edit | students#edit | Edit student form |
| PATCH/PUT | /students/:id | students#update | Update student |
| DELETE | /students/:id | students#destroy | Delete student |
| GET | /students/:student_id/notes | notes#index | List notes for a student |
| GET | /students/:student_id/notes/new | notes#new | New note form |
| POST | /students/:student_id/notes | notes#create | Create note for a student |
| GET | /students/:student_id/notes/:id | notes#show | Show note |
| GET | /students/:student_id/notes/:id/edit | notes#edit | Edit note form |
| PATCH/PUT | /students/:student_id/notes/:id | notes#update | Update note |
| DELETE | /students/:student_id/notes/:id | notes#destroy | Delete note |

### Parameter nesting

- **Students**: payload must be under `student` (e.g., `{ "student": { "name": "..." } }`).
- **Notes**: payload must be under `note` (e.g., `{ "note": { "content": "..." } }`).

### Status codes and redirects

- Success on create/update/destroy: 302 redirect to the relevant page.
- Validation failures: 200 re-render of `new`/`edit` with errors.
