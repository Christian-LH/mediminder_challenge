class UserServicesController < ApplicationController
  before_action :set_profile
  before_action :set_user_service, only: [:show, :edit, :update, :destroy]

  def index
    @user_services = @profile.user_services.includes(:service)
    # @user_services = UserService.all

    # @user_age = current_user.profile.age
    # @user_services = @user_services.joins(:service).where(services: { gender_restriction: current_user.profile.gender })
    #                                                 .where("services.recommended_start_age <= ? AND services.recommended_end_age >= ?", @user_age, @user_age)
    # Filtering with search query - to be implemented later:
      # if params[:query].present?
      #   sql_subquery = "name ILIKE :query OR description ILIKE :query"
      #   @user_services = @user_services.services.where(sql_subquery, query: "%#{params[:query]}%")
      # end
  end

  def show
  end

  def edit
    # @user_service is already set by before_action
  end

  def update
  end

  def destroy
    @user_service.destroy
    redirect_to profile_user_services_path(@profile)
  end

  private

  def set_user_service
    @user_service = @profile.user_services.find(params[:id])
  end

  def set_profile
    # earlier stage without User-Scope:
    # @profile = Profile.find(params[:profile_id])
    @profile = Profile.find(params[:profile_id])
  end
end
