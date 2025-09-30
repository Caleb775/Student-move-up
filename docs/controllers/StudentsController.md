## StudentsController

Public REST endpoints managing `Student` records. Responses are HTML; on success, actions redirect. For API-style usage, send JSON and follow redirects with `-L`.

### Endpoints

| Method | Path | Action | Purpose |
|---|---|---|---|
| GET | /students | index | List students (sorted by `percentage` desc) |
| GET | /students/new | new | New student form |
| POST | /students | create | Create a student |
| GET | /students/:id | show | Show a student |
| GET | /students/:id/edit | edit | Edit student form |
| PATCH/PUT | /students/:id | update | Update a student |
| DELETE | /students/:id | destroy | Delete a student |

### Parameters

Wrap payload under `student`.

- `name` (string, required)
- `reading` (integer 0..10, required)
- `writing` (integer 0..10, required)
- `listening` (integer 0..10, required)
- `speaking` (integer 0..10, required)

Server-side computed (by controller):

- `total_score` = `reading + writing + listening + speaking`
- `percentage` = `(total_score / 40.0) * 100`

Note: Creating/updating outside the controller (e.g., console, seeds) will NOT auto-compute these values.

### Examples

#### List students

```bash
curl -s http://localhost:3000/students | head -n 20
```

#### Create student (JSON)

```bash
curl -i -L \
  -H "Content-Type: application/json" \
  -d '{
    "student": {"name":"Alice","reading":8,"writing":9,"listening":7,"speaking":8}
  }' \
  -X POST http://localhost:3000/students
```

Expected: 302 redirect then 200 OK page. The server computes `total_score=32`, `percentage=80.0`.

#### Update student (partial update)

```bash
curl -i -L \
  -H "Content-Type: application/json" \
  -d '{"student": {"reading":10,"writing":10,"listening":10,"speaking":10}}' \
  -X PATCH http://localhost:3000/students/1
```

#### Delete student

```bash
curl -i -L -X DELETE http://localhost:3000/students/1
```

#### Validation errors

If any of `reading`/`writing`/`listening`/`speaking` are outside 0..10 or missing, the `new`/`edit` view is re-rendered with errors (HTTP 200). Example invalid payload:

```bash
curl -i \
  -H "Content-Type: application/json" \
  -d '{"student": {"name":"Bob","reading":11,"writing":5,"listening":5,"speaking":5}}' \
  -X POST http://localhost:3000/students
```

### Notes

- Sorting: `index` orders by `percentage` descending.
- Strong params: Only listed attributes are permitted.
