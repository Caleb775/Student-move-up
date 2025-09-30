## Note model

### Attributes

| Name | Type | Notes |
|---|---|---|
| id | bigint | Primary key |
| content | text | Required, 1..1000 chars |
| student_id | bigint | Foreign key to `students.id`, required |
| created_at | datetime | |
| updated_at | datetime | |

### Associations

- `belongs_to :student`

### Validations

- `content`: presence, length 1..1000

### Usage examples

```ruby
student = Student.find(1)
student.notes.create!(content: "Great progress on listening.")
```
