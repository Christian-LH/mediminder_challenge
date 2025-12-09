class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update]
  # when creating a new profile, it should automatically also create the user_services that belong to the profile (so for the correct gender and age group)
  # when the profile and the user_services are created, the user should be redirected to the user_services index page for that profile

  def index
    @user_profiles = Profile.where(user: current_user)
  end

  def show
  end

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.user = current_user

    if @profile.save
      create_user_services_for(@profile)
      redirect_to profile_user_services_path(@profile)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      # create user services only if none exist yet
      create_user_services_for(@profile) if @profile.user_services.empty?
      redirect_to profile_user_services_path(@profile), notice: "Profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:gender, :birthday, :user_name, :icon)
  end

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def create_user_services_for(profile)
    return unless profile.present?

    Service.find_each do |service|
      # gender restriction
      if service.gender_restriction.present? && profile.gender.present? && service.gender_restriction != profile.gender  && service.gender_restriction != 'any'
        next
      end

      # skip if profile already older than recommended_end_age
      if service.recommended_end_age.present? && profile.age.present? && profile.age > service.recommended_end_age
        next
      end

      due_date =  if service.recommended_start_age.present? && profile.age.present? && profile.age < service.recommended_start_age && profile.birthday.present?
                    profile.birthday + service.recommended_start_age.years
                  else
                    Date.today
                  end

      UserService.create!(service: service, profile: profile, due_date: due_date, status: 'pending')
    end
  end
end
