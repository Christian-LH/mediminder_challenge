class RiskAssessorsController < ApplicationController
  before_action :authenticate_user!
  # load profile from the URL (nested route: /profiles/:profile_id/...)
  before_action :set_profile
  # load all user_services for this profile to pass them to RiskAssessor.
  before_action :set_user_services

  # constant question to show to user. HEREDOC formats it.
  QUESTION_PROMPT = <<~TEXT.freeze
    To tailor your preventive-care plan, please describe in your own words
    • your occupation,
    •  where you live,
    •  typical travel patterns
    and any other relevant health factors.
  TEXT

  # use `new` action as single-page UI for risk assessor.
  # 1. Set `@question_prompt` so the view can display the standard question.
  #
  # 2. Read any `message` parameter from the request
  #
  # 3. If the user has submitted a message:
  #    a) Call the `RiskAssessor` service (!!!) with:
  #      - current_user (logged-in user)
  #      - @profile (current profile)
  #      - @user_services (all services for this profile)
  #      - user_message (the risk description)
  #    b) Store the returned HTML in `@llm_response` so the view can render it.
  # 4. If there is no message yet (first visit / empty form):
  #    - Set `@llm_response` to nil so the view knows not to show recommendations yet.
  def new
    @question_prompt = QUESTION_PROMPT
    user_message = params[:message]
    # Call LLM only if user has submitted input
    if user_message.present?
      @llm_response = RiskAssessor.call(
        user: current_user,
        profile: @profile,
        user_services: @user_services,
        message: user_message
      )
    else
      @llm_response = nil
    end
  end

  # `create` is broke, just keeping it for documentation
  def create
    head :method_not_allowed
  end

  private

  # load the profile based on `profile_id` from the URL.
  # Store it in `@profile`.
  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  # load all user_services for the current profile, including the service records.
  # Store result in `@user_services`.
  def set_user_services
    @user_services = @profile.user_services.includes(:service)
  end
end
