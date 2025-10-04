class NotesController < ApplicationController
  before_action :set_student
  load_and_authorize_resource through: :student

  def index
    @notes = @student.notes.order(created_at: :desc)
  end

  def show
  end

  def new
  end

  def create
    @note.user = current_user if current_user
    if @note.save
      redirect_to student_path(@student), notice: "Note was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @note.update(note_params)
      redirect_to student_path(@student), notice: "Note was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @note.destroy
    redirect_to student_path(@student), notice: "Note was successfully deleted."
  end

  private

  def set_student
    @student = Student.find(params[:student_id])
  end

  def note_params
    params.require(:note).permit(:content, :user_id)
  end
end
