class Api::V1::NotesController < Api::V1::BaseController
  before_action :set_student
  before_action :set_note, only: [ :show, :update, :destroy ]

  def index
    @notes = @student.notes.includes(:user).order(created_at: :desc)

    # Apply filters
    @notes = @notes.where("content ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @notes = @notes.where(user: current_user) if params[:my_notes] == "true"

    # Pagination
    page = params[:page] || 1
    per_page = [ params[:per_page] || 10, 100 ].min

    @notes = @notes.page(page).per(per_page)

    render json: {
      notes: @notes.map { |note| note_json(note) },
      pagination: {
        current_page: @notes.current_page,
        total_pages: @notes.total_pages,
        total_count: @notes.total_count,
        per_page: per_page
      }
    }
  end

  def show
    render json: {
      note: note_json(@note)
    }
  end

  def create
    @note = @student.notes.build(note_params.merge(user: current_user))

    if @note.save
      render json: {
        note: note_json(@note),
        message: "Note created successfully"
      }, status: :created
    else
      render_error(@note.errors.full_messages.join(", "))
    end
  end

  def update
    if @note.update(note_params)
      render json: {
        note: note_json(@note),
        message: "Note updated successfully"
      }
    else
      render_error(@note.errors.full_messages.join(", "))
    end
  end

  def destroy
    if @note.destroy
      render json: { message: "Note deleted successfully" }
    else
      render_error("Failed to delete note")
    end
  end

  private

  def set_student
    @student = current_user.students.find(params[:student_id])
  rescue ActiveRecord::RecordNotFound
    render_error("Student not found", :not_found)
  end

  def set_note
    @note = @student.notes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Note not found", :not_found)
  end

  def note_params
    params.require(:note).permit(:content)
  end

  def note_json(note)
    {
      id: note.id,
      content: note.content,
      created_at: note.created_at,
      updated_at: note.updated_at,
      created_by: {
        id: note.user&.id,
        name: note.user&.full_name,
        email: note.user&.email
      }
    }
  end
end
