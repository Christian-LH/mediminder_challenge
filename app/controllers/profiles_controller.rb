class ProfilesController < ApplicationController

  VACC_SERVICES = [
    # --- Vaccinations (Adults, STIKO Recommendations) ---
    {
      name: "Tetanus & Diphtheria (Booster)",
      description: "Regular booster every 10 years. At least once in adulthood combined with pertussis (Tdap).",
      category: "vaccination",
      gender_restriction: "any",
      recommended_start_age: 18,
      frequency_months: 120
    },
    {
      name: "Measles Vaccination",
      description: "Single vaccination for all adults born after 1970 with unclear vaccination status or only one childhood dose.",
      category: "vaccination",
      gender_restriction: "any",
      recommended_start_age: 18,
      frequency_months: nil
    },
    {
      name: "Flu Vaccination (Influenza)",
      description: "Annual vaccination in autumn (Oct/Nov). Standard recommendation from age 60, plus pregnant women and chronically ill persons.",
      category: "vaccination",
      gender_restriction: "any",
      recommended_start_age: 60,
      frequency_months: 12
    },
    {
      name: "Pneumococcal Vaccination",
      description: "Protection against pneumonia. Standard vaccination from age 60.",
      category: "vaccination",
      gender_restriction: "any",
      recommended_start_age: 60,
      frequency_months: nil
    },
    {
      name: "Shingles (Herpes Zoster)",
      description: "Two doses 2–6 months apart. Standard recommendation from age 60 (from 50 with underlying conditions).",
      category: "vaccination",
      gender_restriction: "any",
      recommended_start_age: 60,
      frequency_months: nil
    },
    {
      name: "COVID-19 Vaccination",
      description: "Annual booster in autumn for adults over 60 and risk groups. Basic immunity (3 exposures) recommended for all adults.",
      category: "vaccination",
      gender_restriction: "any",
      recommended_start_age: 60,
      frequency_months: 12
    }
  ]

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

      if @profile.vaccination_passes.attached?
        vaccinations = extract_vaccinations_from_pass(@profile)
        Rails.logger.info("ProfilesController#update: vaccinations extracted: #{vaccinations.inspect}")
        processed_count = @profile.mark_vaccinations_as_completed!(vaccinations)
        Rails.logger.info("ProfilesController#update: processed_count=#{processed_count}")
      end

      redirect_to profile_user_services_path(@profile)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:gender, :birthday, vaccination_passes: [])
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
    return [] unless profile.vaccination_passes.attached?
    Rails.logger.info("extract_vaccinations_from_pass: starting for profile=#{profile.id}")

    results = []
    profile.vaccination_passes.each do |attachment|
      attachment.open(tmpdir: Dir.tmpdir) do |file|
        Rails.logger.info("extract_vaccinations_from_pass: opened file at=#{file.path} (blob id=#{attachment.blob.id})")
        @chat = RubyLLM.chat(model: "gpt-4o")

        instructions = <<-PROMPT
          You are an assistant for a German preventive health app.
          You read German vaccination passes ("Impfausweis" / "Impfpass") and extract
          the vaccinations that a single person has already received.

          Return ONLY valid JSON (no Markdown, no extra text) in this exact format:

          [
            {
              "name": "short vaccine name",
              "description": "short description of what the vaccine is about",
              "date": "YYYY-MM-DD or null if you cannot read the exact date"
            }
          ]

          If the vaccination is in the following list, use EXACTLY the "name" from this list: #{VACC_SERVICES}

          If it is a vaccination NOT in the above list, still include it with the name as read from the pass.

          Rules:
          - If a vaccine appears multiple times, include every dose as a separate object.
          - If the vaccine date is approximate (e.g., only month/year), use the first day of that month.
          - If vaccine name is in the above list, use EXACTLY the "name" from that list.
          - If vaccine name is not in the list above, use the name as read from the vaccination pass.
          - If you are unsure about the date, use null.
        PROMPT

        begin
          Rails.logger.info("extract_vaccinations_from_pass: sending file to RubyLLM model")
          response = @chat.with_instructions(instructions).ask(
            "Read this vaccination record and return the vaccinations in the JSON format described.",
            with: file.path
          )

          if response.nil?
            Rails.logger.error("extract_vaccinations_from_pass: RubyLLM returned nil response for blob id=#{attachment.blob.id}")
            next
          end

          raw = response.content
          Rails.logger.info("extract_vaccinations_from_pass: raw response length=#{raw.to_s.length} for blob id=#{attachment.blob.id}")
          Rails.logger.debug("extract_vaccinations_from_pass: raw response=\n#{raw}")

          # sanitize as before
          sanitized = raw.to_s.dup
          sanitized.gsub!(/\A```(?:\w+)?\s*/m, '')
          sanitized.gsub!(/\s*```\s*\z/m, '')
          first = sanitized.index(/[\[{]/)
          last  = sanitized.rindex(/[\]}]/)
          if first && last && last > first
            sanitized = sanitized[first..last]
          end

          Rails.logger.debug("extract_vaccinations_from_pass: sanitized response=\n#{sanitized}")

          data = JSON.parse(sanitized)
          parsed = data.map do |item|
            {
              name: item["name"],
              description: item["description"],
              date: item["date"].present? ? Date.parse(item["date"]) : nil
            }
          end

          results.concat(parsed)
        rescue JSON::ParserError => e
          Rails.logger.error("extract_vaccinations_from_pass: JSON parse error for blob id=#{attachment.blob.id}: #{e.message}")
          Rails.logger.debug("extract_vaccinations_from_pass: raw response was: #{raw}")
          next
        rescue StandardError => e
          Rails.logger.error("extract_vaccinations_from_pass: error calling RubyLLM for blob id=#{attachment.blob.id}: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          next
        end
      end
    end

    results
  rescue StandardError => e
    Rails.logger.error("extract_vaccinations_from_pass: unexpected error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    []
  end
end
