class UserServicesController < ApplicationController
  # before_action :set_user_service, only: [:show, :edit, :update]

  def index
    @user_services = UserService.all
  end

  # def show
  # end

  def new
    @user_service = UserService.new
  end

  def create
    @user_service = UserService.new(user_service_params)
    if @user_service.save
      redirect_to user_services_path, notice: 'User service was successfully created.'
    else
      render :new
    end
  end

  # def edit
  # end

  # def update
  # end

  private

  # def set_user_service
  #   @user_service = User.profiles.user_services.find(params[:id])
  # end
end
