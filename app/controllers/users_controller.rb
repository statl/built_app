class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  include WorkoutsHelper
  
  def index
	@users = User.paginate(page: params[:page])
  end
  
  def show
    @user = User.find_by_nickname(params[:nickname])
	@workouts = @user.workouts.paginate(page: params[:page])
  end
  
  def new
	@user = User.new
  end
  
  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to user_path
    else
      render 'edit'
    end
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
	  sign_in @user
	  flash[:success] = "Welcome to the I am Built Test App!"
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation,
								   :nickname)
    end
  
    # Before filters

    def correct_user
      @user = User.find_by_nickname(params[:nickname])
      redirect_to(root_url) unless current_user?(@user)
    end
	
	def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end