class UserServicesController < ApplicationController
  before_action :set_profile
  before_action :set_user_service, only: [:show, :edit, :update, :destroy, :mark_done, :mark_discard]

  def index
    # Order pending services to show closest due dates on top
    @user_services = @profile.user_services.includes(:service).ordered_for_index
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

  def mark_done
    if @user_service.service.category == "vaccination"
      @profile.mark_vaccinations_as_completed!([
        {
          name: @user_service.service.name,
          date: Date.today,
          description: "Confirmed manually"
        }
      ])
    else
      @user_service.update!(
        status: "done",
        completed_at: Date.today,
        due_date: (@user_service.due_date || Date.today)
      )

      # Recurring services are added back to the list with updated due date when marked done
      freq = @user_service.service.frequency_months
      if freq.present? && freq.to_i > 0
        next_due = Date.today + freq.to_i.months
        UserService.create!(
          profile: @profile,
          service: @user_service.service,
          due_date: next_due,
          status: "pending"
        )
      end
    end

    redirect_to profile_user_services_path(@profile),
                notice: "Service marked as done."
  end

  def mark_discard
    @user_service.update!(status: "discard")

    redirect_to profile_user_services_path(@profile),
                notice: "Service discarded."
  end

  def history
    @user_services = @profile.user_services.where(status: "done").ordered_for_history
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
