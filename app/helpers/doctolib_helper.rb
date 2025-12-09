# app/helpers/doctolib_helper.rb
module DoctolibHelper
  DOCTOLIB_SPECIALTIES = {
    # --- General checkups / Vorsorge Hausarzt ---
    "General Health Check-up (One-time)" => "allgemeinarzt",
    "General Health Check-up (Over 35)"  => "allgemeinarzt",
    "Blood Pressure Check"               => "allgemeinarzt",
    "Cholesterol Check"                  => "allgemeinarzt",

    # --- Dental ---
    "Dental Checkup"                     => "zahnarzt",
    "Professional Teeth Cleaning"        => "zahnarzt",

    # --- Skin / cancer screening ---
    "Skin Cancer Check"                  => "hautarzt",
    "Skin Cancer Screening"              => "hautarzt",
    "Dermatology Check"                  => "hautarzt",

    # --- Women’s health ---
    "Gynecological Check-up"             => "frauenarzt",
    "Cervical Cancer Screening (Pap smear)" => "frauenarzt",
    "Breast Cancer Screening (Mammography)" => "radiologe",
    "Contraception / Pill Check"         => "frauenarzt",

    # --- Men’s health ---
    "Prostate Cancer Screening"          => "urologe",
    "Urology Check-up"                   => "urologe",

    # --- Colon / intestine ---
    "Colon Cancer Screening (Colonoscopy)"   => "gastroenterologe",
    "Colon Cancer Screening (Stool Test)"    => "allgemeinarzt",

    # --- Eye / Ophthalmology ---
    "Eye Check-up"                       => "augenarzt",
    "Glaucoma Screening"                 => "augenarzt",

    # --- ENT / HNO ---
    "ENT Check-up"                       => "hno-arzt",
    "Hearing Test"                       => "hno-arzt",

    # --- Cardio / heart ---
    "Cardiovascular Risk Check"          => "kardiologe",
    "ECG Check"                          => "kardiologe",

    # --- Lungs / Pneumo ---
    "Lung Function Check"                => "pneumologe",

    # --- Orthopedics / musculoskeletal ---
    "Orthopedic Check-up"                => "orthopade",
    "Back Pain Check"                    => "orthopade",
    "Bone Density Measurement"           => "orthopade",

    # --- Neurology / mental health ---
    "Neurology Check-up"                 => "neurologe",
    "Depression Screening"               => "psychologischer-psychotherapeut",

    # --- Vaccinations – adults (typically GP) ---
    "Flu Vaccine"                        => "allgemeinarzt",
    "COVID-19 Vaccine"                   => "allgemeinarzt",
    "Tetanus / Diphtheria / Pertussis Booster" => "allgemeinarzt",
    "Measles / Mumps / Rubella Vaccine (Adult)" => "allgemeinarzt",
    "Pneumococcal Vaccine"               => "allgemeinarzt",
    "Herpes Zoster (Shingles) Vaccine"   => "allgemeinarzt",
    "HPV Vaccine (Adult)"                => "allgemeinarzt",
    "Travel Vaccination Check"           => "allgemeinarzt",

    # --- Pediatric check-ups and vaccines ---
    "Pediatric Check-up"                 => "kinderarzt",
    "U1–U9 Check-ups"                    => "kinderarzt",
    "Pediatric Vaccination"              => "kinderarzt",

    # --- Pregnancy / postnatal ---
    "Prenatal Check-up"                  => "frauenarzt",
    "Postnatal Check-up"                 => "frauenarzt",

    # --- Other common preventive services ---
    "Bone Health Check (Osteoporosis)"   => "orthopade",
    "Allergy Check"                      => "allergologe",
    "Thyroid Check"                      => "endokrinologe"
  }.freeze

  # Returns a Doctolib speciality slug for a given service name.
  # If there is no explicit mapping, use "allgemeinarzt" as a safe default.
  def doctolib_speciality_for(service_name)
    DOCTOLIB_SPECIALTIES[service_name] || "allgemeinarzt"
  end

  # Builds the full Doctolib search URL for a given service name.
  def doctolib_url_for(service_name)
    speciality = doctolib_speciality_for(service_name)
    "https://www.doctolib.de/search?location=deutschland&speciality=#{speciality}"
  end
end
