class UserServicesController < ApplicationController
  # before_action :set_user_service, only: [:show, :edit, :update]

  def index
    @user_services = UserService.all

    @user_age = current_user.profile.age
    @user_services = @user_services.joins(:service).where(services: { gender_restriction: current_user.profile.gender })
    .where("services.recommended_start_age <= ? AND services.recommended_end_age >= ?", @user_age, @user_age)

    # Filtering with search query - to be implemented later:
      # if params[:query].present?
      #   sql_subquery = "name ILIKE :query OR description ILIKE :query"
      #   @user_services = @user_services.services.where(sql_subquery, query: "%#{params[:query]}%")
      # end
  end

  # def show
  # end

  # def new
  #   @user_service = UserService.new
  # end

  # def create
  # end

  # def edit
  # end

  # def update
  # end

  private

  # def set_user_service
  #   @user_service = User.profiles.user_services.find(params[:id])
  # end
end
