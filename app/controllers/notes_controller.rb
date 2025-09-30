class NotesController < ApplicationController
  before_action :set_student
  before_action :set_note, only: [ :show, :edit, :update, :destroy ]

  def index
    @notes = @student.notes.order(created_at: :desc)
  end

  def show
  end

  def new
    @note = @student.notes.build
  end

  def create
    @note = @student.notes.build(note_params)
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

  def set_note
    @note = @student.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:content)
  end
end
