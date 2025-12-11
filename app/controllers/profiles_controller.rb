class ProfilesController < ApplicationController

  VACC_SERVICES = [
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
    params.require(:profile).permit(:gender, :birthday, :user_name, :icon, vaccination_passes: [])
  end

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def create_user_services_for(profile)
    return unless profile.present?

    Service.find_each do |service|
      # Skip services that were imported from vaccination passes (only if the column exists)
      next if Service.column_names.include?("imported") && service.imported?

      # gender restriction
      if service.gender_restriction.present? && profile.gender.present?
        # gender is stored with symbols (♂, ♀)
        # Strip to make it only "male" and "female"
        srv_gender = service.gender_restriction.to_s.downcase.gsub(/[^a-z]/, '')
        prof_gender = profile.gender.to_s.downcase.gsub(/[^a-z]/, '')
        if srv_gender != 'any' && srv_gender != prof_gender
          next
        end
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

            You have the following list of standardised vaccine service names:
            #{VACC_SERVICES}

            YOUR GOAL
            - Extract EVERY vaccination you can identify from the vaccination pass.
            - The list above is ONLY for normalising names. It is NOT a filter.
            - Do NOT skip or drop a vaccination just because it is not in the list.

            INCLUSION RULES (VERY IMPORTANT)
            - For every vaccination entry you can read (brand, disease name, combination, etc.), create at least one JSON object.
            - Do not apply any medical judgement (e.g. age, importance, “only basic vaccines”). If it appears in the pass and you can recognise it, you must output it.
            - This includes travel vaccines, special vaccines, or any others that are not part of the standard list (e.g. FSME, Gelbfieber, Typhus, Tollwut, Herpes zoster, etc.).

            MAPPING & NORMALISATION RULES
            1. Matching to standard services
              - Try to map each vaccination to the MOST APPROPRIATE existing service name from the list above.
              - If the entry is a BRAND NAME (e.g. "Priorix", "M-M-RVAXPRO", "Infanrix", "Infanrix hexa", "Boostrix", "Comirnaty", "Spikevax", etc.), infer which diseases it protects against.
              - If there is a semantically equivalent service in the list (e.g. Measles, Mumps, Rubella, Tetanus, Diphtheria, Pertussis, Polio, HPV, Hepatitis B, Covid-19, etc.), use EXACTLY that name from the list instead of the brand name.

            2. Combination vaccines
              - For combination vaccines (e.g. MMR, Priorix, Infanrix hexa, 6-fach-Impfung, Tdap, etc.):
                - Return ONE JSON OBJECT PER DISEASE / COMPONENT that appears in the list.
                - Use the SAME DATE for all components of the combination.
                - Example: If the pass shows "Priorix", and the list contains services for Measles, Mumps and Rubella, output three separate objects with the names from the list (e.g. "Measles Vaccination", "Mumps Vaccination", "Rubella Vaccination") instead of a single "Priorix" entry.
                - Example: If the pass shows "Boostrix" and the list contains a combined "Tetanus & Diphtheria (Booster)" service, use EXACTLY "Tetanus & Diphtheria (Booster)" as the name, not "Boostrix".

            3. Synonyms and abbreviations
              - Treat common abbreviations as synonyms (e.g. "MMR", "M-M-R", "Masern-Mumps-Röteln").
              - Treat German and English disease names as equivalent (e.g. "Masern" = "Measles", "Röteln" = "Rubella", "Keuchhusten" = "Pertussis").
              - If the vaccine name on the pass is a known abbreviation, brand, or short form of a vaccine in the list, use EXACTLY the matching name from the list.

            4. Vaccines NOT in the list
              - If you cannot reasonably map a vaccination to any entry in the list, STILL INCLUDE IT.
              - In that case:
                - Use the name as written on the vaccination pass (or a clear short form, e.g. "FSME", "Gelbfieber", "Typhus").
                - Do NOT try to force it into an unrelated name from the list.
              - Example: If the pass shows "FSME" and there is no tick-borne encephalitis service in the list, output an entry with "name": "FSME".

            MULTIPLE DOSES OF THE SAME VACCINE (IMPORTANT)
            - NEVER merge or deduplicate multiple doses.
            - If the same vaccine (same mapped name) appears more than once with different dates, output ONE OBJECT PER DOSE.
            - Naming pattern per vaccine name:
              - For the FIRST dose of a vaccine that is in the standard list, use the name EXACTLY as in the list.
              - For each ADDITIONAL dose of the same vaccine, append a running number in brackets to the name.
                - Example (COVID-19 in the list as "COVID-19 Vaccination"):
                  - 1st dose (earliest date): "name": "COVID-19 Vaccination"
                  - 2nd dose: "name": "COVID-19 Vaccination (2)"
                  - 3rd dose: "name": "COVID-19 Vaccination (3)"
                - Example (Measles Vaccination):
                  - 1st dose: "Measles Vaccination"
                  - 2nd dose: "Measles Vaccination (2)"
            - Apply the same pattern to vaccines NOT in the list as well (using their pass name):
              - 1st dose: "FSME"
              - 2nd dose: "FSME (2)"
              - 3rd dose: "FSME (3)"
            - The numbering is per vaccine name (per disease/component), ordered by date from earliest (1) to latest.

            DATE RULES
            - If the vaccination is given multiple times (series / boosters), include EVERY DOSE as a separate object (with the naming and numbering rules above).
            - If the date is approximate (e.g. only month/year), use the first day of that month: "YYYY-MM-01".
            - If you truly cannot read or infer the date, use null.

            DESCRIPTION FIELD
            - The "description" field should be a brief summary of the vaccine’s purpose in plain language.
              - Example: "Vaccine against measles", "Booster for tetanus and diphtheria", "Vaccine against tick-borne encephalitis (FSME)".

            REMINDERS
            - ALWAYS return a JSON ARRAY of vaccine objects.
            - NEVER output Markdown, comments, or any extra text outside the JSON.
            - ALWAYS include:
              - Vaccines that match the standard list (with the normalised name and numbered doses).
              - Vaccines that do not match the list (with the name from the pass and numbered doses, if multiple).
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
