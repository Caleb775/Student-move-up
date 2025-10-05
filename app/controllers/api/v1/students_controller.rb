class Api::V1::StudentsController < Api::V1::BaseController
  before_action :set_student, only: [ :show, :update, :destroy ]

  def index
    @students = current_user.students.includes(:notes)

    # Apply filters
    @students = @students.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @students = @students.where("total_score >= ?", params[:min_score]) if params[:min_score].present?
    @students = @students.where("total_score <= ?", params[:max_score]) if params[:max_score].present?

    # Pagination
    page = params[:page] || 1
    per_page = [ params[:per_page] || 10, 100 ].min # Max 100 per page

    @students = @students.page(page).per(per_page)

    render json: {
      students: @students.map { |student| student_json(student) },
      pagination: {
        current_page: @students.current_page,
        total_pages: @students.total_pages,
        total_count: @students.total_count,
        per_page: per_page
      }
    }
  end

  def show
    render json: {
      student: student_json(@student, include_notes: true)
    }
  end

  def create
    @student = current_user.students.build(student_params)

    if @student.save
      render json: {
        student: student_json(@student),
        message: "Student created successfully"
      }, status: :created
    else
      render_error(@student.errors.full_messages.join(", "))
    end
  end

  def update
    if @student.update(student_params)
      render json: {
        student: student_json(@student),
        message: "Student updated successfully"
      }
    else
      render_error(@student.errors.full_messages.join(", "))
    end
  end

  def destroy
    if @student.destroy
      render json: { message: "Student deleted successfully" }
    else
      render_error("Failed to delete student")
    end
  end

  def stats
    students = current_user.students

    stats = {
      total_students: students.count,
      average_score: students.average(:total_score)&.round(2) || 0,
      average_percentage: students.average(:percentage)&.round(2) || 0,
      top_performer: students.order(total_score: :desc).first&.name,
      skills_average: {
        reading: students.average(:reading)&.round(2) || 0,
        writing: students.average(:writing)&.round(2) || 0,
        listening: students.average(:listening)&.round(2) || 0,
        speaking: students.average(:speaking)&.round(2) || 0
      },
      score_distribution: {
        excellent: students.where("percentage >= 90").count,
        good: students.where("percentage >= 80 AND percentage < 90").count,
        average: students.where("percentage >= 70 AND percentage < 80").count,
        below_average: students.where("percentage >= 60 AND percentage < 70").count,
        needs_improvement: students.where("percentage < 60").count
      }
    }

    render json: { stats: stats }
  end

  private

  def set_student
    @student = current_user.students.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Student not found", :not_found)
  end

  def student_params
    params.require(:student).permit(:name, :reading, :writing, :listening, :speaking)
  end

  def student_json(student, include_notes: false)
    json = {
      id: student.id,
      name: student.name,
      reading: student.reading,
      writing: student.writing,
      listening: student.listening,
      speaking: student.speaking,
      total_score: student.total_score,
      percentage: student.percentage.round(2),
      created_at: student.created_at,
      updated_at: student.updated_at
    }

    if include_notes
      json[:notes] = student.notes.map { |note| note_json(note) }
    else
      json[:notes_count] = student.notes.count
    end

    json
  end

  def note_json(note)
    {
      id: note.id,
      content: note.content,
      created_at: note.created_at,
      updated_at: note.updated_at,
      created_by: note.user&.full_name
    }
  end
end
