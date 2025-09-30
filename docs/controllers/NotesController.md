## NotesController

Nested REST endpoints under a `Student`. Responses are HTML; on success, actions redirect to the student page.

### Endpoints

| Method | Path | Action | Purpose |
|---|---|---|---|
| GET | /students/:student_id/notes | index | List notes for a student |
| GET | /students/:student_id/notes/new | new | New note form |
| POST | /students/:student_id/notes | create | Create a note |
| GET | /students/:student_id/notes/:id | show | Show a note |
| GET | /students/:student_id/notes/:id/edit | edit | Edit note form |
| PATCH/PUT | /students/:student_id/notes/:id | update | Update a note |
| DELETE | /students/:student_id/notes/:id | destroy | Delete a note |

### Parameters

Wrap payload under `note`.

- `content` (string, 1..1000 chars, required)

### Examples

Assume `student_id=1` exists.

#### List notes

```bash
curl -s http://localhost:3000/students/1/notes | head -n 20
```

#### Create a note (JSON)

```bash
curl -i -L \
  -H "Content-Type: application/json" \
  -d '{"note": {"content":"Great progress on listening."}}' \
  -X POST http://localhost:3000/students/1/notes
```

#### Update a note

```bash
curl -i -L \
  -H "Content-Type: application/json" \
  -d '{"note": {"content":"Updated: Excellent participation."}}' \
  -X PATCH http://localhost:3000/students/1/notes/5
```

#### Delete a note

```bash
curl -i -L -X DELETE http://localhost:3000/students/1/notes/5
```

#### Validation errors

Blank or overly long content re-renders the form (HTTP 200) with errors.

### Notes

- Notes are ordered by `created_at DESC` in `index`.
