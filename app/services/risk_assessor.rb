# ERB helper to escape HTML (e.g., service names).
# needs to be understood
require "erb"

class RiskAssessor
  # Include URL helpers.
  include Rails.application.routes.url_helpers

  # class-level `call` method so I can use `RiskAssessor.call(...)`
  # 1. When I call this from controller, I pass:
  #   - current user
  #   - current profile
  #   - list of user_services
  #   - user message
  # 2. Then instantiate a new RiskAssessor with these arguments and run the `call` method.
  def self.call(user:, profile:, user_services:, message:, return_to: nil)
    new(user, profile, user_services, message, return_to).call
  end

  # store all dependenciesin instance variable.
  def initialize(user, profile, user_services, message, return_to = nil)
    @user          = user
    @profile       = profile
    @user_services = user_services
    @message       = message
    @return_to     = return_to
  end


  # 1. Build a JSON context that contains:
  #    - age, gender, available services with id, name, category, and link path.
  # 2. Decide what the "user input" for the LLM should be (according to message or no message)
  # 3. Construct a full prompt that contains:
  #    - a system instruction (how the LLM should behave),
  #    - the JSON context,
  #    - the user input,
  #    - and a task description telling the LLM to output HTML.
  # 4. Ask the LLM (via RubyLLM) for a response:
  #    - Call `ask` with the full prompt.
  #    - Extract the text content from the response (handle both `.content` and direct string).
  # 5. If the LLM returned non-empty text, use it as the HTML result.
  # 6. If error, fall back to a simple built-in HTML view that shows top 3 services.

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

  # 1/3 of full prompt: JSON context object to send to the LLM.
  #
  # 1. Transform `@user_services` into an array of hashes:
  #    - For each user_service:
  #      - take its id
  #      - take the associated service name
  #      - take the service category
  #      - generate the profile-specific URL path to the service detail page.
  # 2. Build a `user` hash with:
  #    - age
  #    - gender
  # 3. Combine `user` and `services` into one hash.
  # 4. Convert hash into JSON so LLM can parse it.
  def build_context
    services_for_llm = @user_services.map do |us|
      path =
        if @return_to.present?                                         # NEW
          profile_user_service_path(@profile, us, return_to: @return_to)
        else
          profile_user_service_path(@profile, us)
        end

      {
        id:       us.id,
        name:     us.service.name,
        category: us.service.category,
        path:     path                                                 # CHANGED
      }
    end


# 2/3 of full prompt: user info to send to the LLM.

    {
      user: {
        email:  @user.email,
        age:    @profile.respond_to?(:age) ? @profile.age : nil,
        gender: @profile.respond_to?(:gender) ? @profile.gender : nil
      },
      services: services_for_llm
    }.to_json
  end

  # Simple HTML fallback in case the LLM call fails

    def build_fallback_html
      html = +"<h3>Unintended error</h3>"

      html << <<~HTML
        <div class="mediminder-recommendation">
          <p>Risk Assessor is currently not available. Please try again later.</p>
        </div>
      HTML

      html
    end

# 3/3 of full prompt: system prompt to the LLM.

  def system_prompt
    <<~PROMPT
      You are the "MediMinder Risk Assessor", an assistant that helps busy adults prioritise preventive checkups and vaccinations based on their personal risk factors.

      You will receive:
      - Basic user profile (age, gender)
      - A list of available preventive-care services (each with name, category, and a `path` to the detail page)

      Read the user’s free-text risk description carefully. Identify concrete or implied risk factors related to occupation, living environment, lifestyle, travel exposure, or pre-existing vulnerabilities. Then map these risk factors to the most relevant preventive-care services provided in the context.
      Act as an experienced preventive-medicine specialist:
      - infer plausible health risks even when they are only indirectly mentioned,
      - form clear, evidence-based associations (e.g., outdoor work → skin cancer screening; frequent air travel → flu vaccination),
      - prioritise services that best address the user’s specific risk exposures,
      - avoid generic or unrelated matches.
      Based on these connections between user risk factors and the available services, your job is to:

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
          <a href="/profiles/3/user_services/12"
           class="btn btn-outline-primary btn-lg w-100 mb-3">
            View service
          </a>
        </div>
      - Use the exact `path` values from the context for the links; do NOT invent new URLs.
      - You MUST output exactly three recommendations.

      The tone should be clear, calm, and supportive.
    PROMPT
  end
end
