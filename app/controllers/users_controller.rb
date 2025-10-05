class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_access
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  skip_authorization_check

  def index
    @q = User.ransack(params[:q])
    @users = @q.result.includes(:students, :notes).order(:role, :last_name, :first_name)
    @users = @users.page(params[:page]).per(10)
  end

  def show
    @user_students = @user.students.order(:name)
    @user_notes = @user.notes.includes(:student).order(created_at: :desc).limit(10)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Handle password updates separately
    if params[:user][:password].present?
      if @user.update(user_params)
        redirect_to @user, notice: "User was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      # Update without password
      if @user.update(user_params.except(:password, :password_confirmation))
        redirect_to @user, notice: "User was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    # Prevent admin from deleting themselves
    if @user == current_user
      redirect_to users_path, alert: "You cannot delete your own account."
      return
    end

    # Check if user has associated data
    if @user.students.any? || @user.notes.any?
      # Reassign data to current admin before deletion
      admin_user = User.find_by(role: 2) # Find another admin
      if admin_user && admin_user != @user
        @user.students.update_all(user_id: admin_user.id)
        @user.notes.update_all(user_id: admin_user.id)
      else
        redirect_to users_path, alert: "Cannot delete user with associated data. Please reassign students and notes first."
        return
      end
    end

    @user.destroy
    redirect_to users_path, notice: "User was successfully deleted."
  end

  def bulk_actions
    case params[:bulk_action]
    when "delete"
      bulk_delete
    when "change_role"
      bulk_change_role
    else
      redirect_to users_path, alert: "Invalid bulk action selected."
    end
  end

  private

  def check_admin_access
    unless current_user.admin?
      redirect_to root_path, alert: "You do not have permission to access user management."
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role, :password, :password_confirmation)
  end

  def bulk_delete
    user_ids = params[:user_ids] || []
    current_user_id = current_user.id

    # Remove current user from deletion list
    user_ids = user_ids.reject { |id| id.to_i == current_user_id }

    if user_ids.empty?
      redirect_to users_path, alert: "No valid users selected for deletion."
      return
    end

    users_to_delete = User.where(id: user_ids)
    admin_user = User.find_by(role: 2) # Find an admin to reassign data to

    users_to_delete.each do |user|
      if user.students.any? || user.notes.any?
        if admin_user && admin_user != user
          user.students.update_all(user_id: admin_user.id)
          user.notes.update_all(user_id: admin_user.id)
        end
      end
    end

    deleted_count = users_to_delete.count
    users_to_delete.destroy_all

    redirect_to users_path, notice: "Successfully deleted #{deleted_count} user(s)."
  end

  def bulk_change_role
    user_ids = params[:user_ids] || []
    new_role = params[:new_role]

    if user_ids.empty? || new_role.blank?
      redirect_to users_path, alert: "Please select users and a new role."
      return
    end

    # Prevent changing current user's role
    user_ids = user_ids.reject { |id| id.to_i == current_user.id }

    if user_ids.empty?
      redirect_to users_path, alert: "Cannot change your own role."
      return
    end

    users_to_update = User.where(id: user_ids)
    updated_count = users_to_update.update_all(role: new_role)

    redirect_to users_path, notice: "Successfully updated role for #{updated_count} user(s)."
  end
end
