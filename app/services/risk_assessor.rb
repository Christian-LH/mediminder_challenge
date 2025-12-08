# app/services/risk_assessor.rb
require "erb"

class RiskAssessor
  include Rails.application.routes.url_helpers

  def self.call(user:, profile:, user_services:, message:)
    new(user, profile, user_services, message).call
  end

  def initialize(user, profile, user_services, message)
    @user          = user
    @profile       = profile
    @user_services = user_services
    @message       = message
  end

  def call
    context    = build_context
    user_input = @message.presence || "Start Risk Assessment."

    full_prompt = <<~TEXT
      SYSTEM INSTRUCTION:
      #{system_prompt}

      CONTEXT (JSON):
      #{context}

      USER INPUT:
      #{user_input}

      TASK:
      Use the system instruction and context above to generate the HTML output for the MediMinder Risk Assessor.
    TEXT

    begin
      chat     = RubyLLM.chat
      response = chat.ask(full_prompt)

      text =
        if response.respond_to?(:content)
          response.content.to_s
        else
          response.to_s
        end

      return text if text.present?
    rescue => e
      Rails.logger.error("[RiskAssessor] LLM error: #{e.class}: #{e.message}")
    end

    build_fallback_html
  end

  private

  def build_context
    services_for_llm = @user_services.map do |us|
      {
        id:       us.id,
        name:     us.service.name,
        category: us.service.category,
        path:     profile_user_service_path(@profile, us)
      }
    end

    {
      user: {
        email:  @user.email,
        age:    @profile.respond_to?(:age) ? @profile.age : nil,
        gender: @profile.respond_to?(:gender) ? @profile.gender : nil
      },
      services: services_for_llm
    }.to_json
  end

  def build_fallback_html
    services = @user_services.first(3)

    html = +"<h3>Top 3 preventive services (fallback)</h3>"

    services.each do |us|
      name = ERB::Util.html_escape(us.service.name)
      path = profile_user_service_path(@profile, us)

      html << <<~HTML
        <div class="mediminder-recommendation">
          <h4>#{name}</h4>
          <p>This is one of your available preventive services. Please review it and consider if it matches your current risk factors.</p>
          <a href="#{path}">View service</a>
        </div>
      HTML
    end

    html
  end

  def system_prompt
    <<~PROMPT
      You are the "MediMinder Risk Assessor", an assistant that helps busy adults prioritise preventive checkups and vaccinations based on their personal risk factors.

      You will receive:
      - Basic user profile (age, gender)
      - A list of available preventive-care services (each with name, category, and a `path` to the detail page)

      Based on the risk description the user provides, your job is to:
      1. Select the three most important services to prioritise for this user.
      2. For each selected service, output in English:
         - the service name
         - a one-sentence justification
         - an HTML link to the service detail page using the provided `path`.

      Output rules:
      - Produce HTML only (no Markdown).
      - Wrap each recommendation in its own block using the CSS class:
        <div class="mediminder-recommendation mb-4">
          <h4>Service name</h4>
          <p>One-sentence justification.</p>
          <a href="/profiles/3/user_services/12" class="btn btn-light rounded-pill mb-3">View service</a>
        </div>
      - Use the exact `path` values from the context for the links; do NOT invent new URLs.
      - You MUST output exactly three recommendations.

      The tone should be clear, calm, and supportive.
    PROMPT
  end
end
