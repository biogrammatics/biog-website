class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    # Eager load the most recent session for each user to avoid N+1 queries
    @users = User.includes(:sessions).all.order(:email_address)
  end

  def show
    # Load recent sessions for the user detail view
    @recent_sessions = @user.sessions.order(created_at: :desc).limit(20)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    # Handle admin field separately for security
    @user.admin = params[:user][:admin] == "1" if params[:user][:admin].present?

    if @user.save
      redirect_to admin_users_path, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Allow updating without changing password
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      # Handle admin field separately for security
      @user.update_column(:admin, params[:user][:admin] == "1") if params[:user][:admin].present?
      redirect_to admin_users_path, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == Current.user
      redirect_to admin_users_path, alert: "You cannot delete your own account."
    else
      @user.destroy
      redirect_to admin_users_path, notice: "User was successfully deleted."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    # Admin field is handled separately for security reasons
    params.require(:user).permit(:email_address, :first_name, :last_name, :password, :password_confirmation, :twist_username)
  end
end
