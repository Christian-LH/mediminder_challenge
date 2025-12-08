class RiskAssessorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile
  before_action :set_user_services

  QUESTION_PROMPT = <<~TEXT.freeze
    To tailor your preventive-care plan, please describe in your own words
    • your occupation,
    •  where you live,
    •  typical travel patterns
    and any other relevant health factors.
  TEXT

  def new
    @question_prompt = QUESTION_PROMPT
    user_message = params[:message]

    if user_message.present?
      # Only call the LLM if the user has submitted an answer
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

  # We keep create for now but do not use it, so it does not affect your team.
  def create
    head :method_not_allowed
  end

  private

  def set_profile
    @profile = current_user.profile
  end

  def set_user_services
    @user_services = @profile.user_services.includes(:service)
  end
end
