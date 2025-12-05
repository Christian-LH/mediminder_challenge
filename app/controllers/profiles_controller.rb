class ProfilesController < ApplicationController

  # when creating a new profile, it should automatically also create the user_services that belong to the profile (so for the correct gender and age group)
  # when the profile and the user_services are created, the user should be redirected to the user_services index page for that profile

  def new
    if current_user.profile.present?
      redirect_to profile_user_services_path(current_user.profile)
    end
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.user = current_user

    begin
      Profile.transaction do
        @profile.save!
        create_user_services_for(@profile)
      end
      redirect_to profile_user_services_path(@profile) # , notice: "Profile was successfully created."
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Profile creation failed: #{e.message}")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @profile = Profile.find(params[:id])
  end

  def update
    @profile = Profile.find(params[:id])

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
    params.require(:profile).permit(:gender, :birthday)
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
