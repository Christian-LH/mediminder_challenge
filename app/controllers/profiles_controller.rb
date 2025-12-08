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

      # If a vaccination pass was uploaded, analyse it with RubyLLM
      if params[:profile][:vaccination_pass].present?
        vaccinations = extract_vaccinations_from_pass(@profile)
        @profile.mark_vaccinations_as_completed!(vaccinations)
      end

      redirect_to profile_user_services_path(@profile)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:gender, :birthday, :vaccination_pass)
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

  def extract_vaccinations_from_pass(profile)
    return [] unless profile.vaccination_pass.attached?
    profile.vaccination_pass.open(tmpdir: Dir.tmpdir) do |file|
      chat = RubyLLM.chat(model: "gpt-4o")

      system_prompt = <<-PROMPT
        You are an assistant for a German preventive health app.
        You read German vaccination passes ("Impfausweis" / "Impfpass") and extract
        the vaccinations that a single person has already received.

        Return ONLY valid JSON (no Markdown, no extra text) in this exact format:

        [
          {
            "name": "short German vaccine name (e.g. 'Tetanus', 'MMR', 'FSME')",
            "date": "YYYY-MM-DD or null if you cannot read the exact date"
          }
        ]

        Rules:
        - Ignore entries that are clearly not vaccinations.
        - If a vaccine appears multiple times, include every dose as a separate object.
        - If you are unsure about the date, use null.
      PROMPT
      # when it can't read one vaccination, it should return something so that the user knows that

      # Set the system prompt
      chat.with_instructions(system_prompt, replace: true)

      # User message + image file
      response = chat.ask(
        "Read this vaccination record and return the vaccinations to me in the JSON format described.",
        with: file.path
      )

      raw = response.content

      data = JSON.parse(raw)
      data.map do |item|
        {
          name: item["name"],
          date: item["date"].present? ? Date.parse(item["date"]) : nil
        }
      end
    end
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse vaccination JSON from LLM: #{e.message}")
      []
    rescue StandardError => e
      Rails.logger.error("Error while analysing vaccination pass: #{e.message}")
      []
  end
end
