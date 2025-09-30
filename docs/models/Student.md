## Student model

### Attributes

| Name | Type | Notes |
|---|---|---|
| id | bigint | Primary key |
| name | string | Required |
| reading | integer | Required, 0..10 |
| writing | integer | Required, 0..10 |
| listening | integer | Required, 0..10 |
| speaking | integer | Required, 0..10 |
| total_score | integer | Computed in controller (not auto-computed in model) |
| percentage | float | Computed in controller (not auto-computed in model) |
| created_at | datetime | |
| updated_at | datetime | |

### Associations

- `has_many :notes, dependent: :destroy`

### Validations

- `name`: presence
- `reading`, `writing`, `listening`, `speaking`: presence and `numericality: { in: 0..10 }`

### Usage examples

#### From the web (controller computes scores)

See `StudentsController` examples; the controller sets `total_score` and `percentage`.

#### From Rails console (manual computation required)

```ruby
student = Student.new(name: "Alice", reading: 8, writing: 9, listening: 7, speaking: 8)
student.total_score = student.reading + student.writing + student.listening + student.speaking # => 32
student.percentage  = (student.total_score / 40.0) * 100                                 # => 80.0
student.save!
```

#### Querying top students

```ruby
Student.order(percentage: :desc).limit(10)
```
