class ProfilesController < ApplicationController
  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      redirect_to profile_user_services_path(current_user, @profile) # supposed to redirect to roadmap view / is current_user necessary?
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:gender, :birthday)
  end
end
