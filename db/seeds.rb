# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleaning the database ..."
UserService.destroy_all
Profile.destroy_all
Notification.destroy_all
User.destroy_all
Service.destroy_all
puts "Cleaned the database"
puts "Creating seed data ..."
# service1 = Service.create(name: "Flu Shot", description: "the vacciantion against the influenza virus", gender_restriction: "male", recommended_start_age: 18, recommended_end_age: 65)
# service2 = Service.create(name: "Prophylaxis", description: "deep cleaning of the teeth", gender_restriction: "male", recommended_start_age: 18, recommended_end_age: 65)


puts "Created #{Service.count} services"
puts "Creating a user with profile and user_service ..."
user = User.create!(email: "bob@gmail.com", password: "Password123")
# profile = Profile.create!(user: user, gender: "male", birthday: Date.new(2002, 3, 7))
# user_service1 = UserService.create!(profile: profile, service: service1, due_date: Date.today + 1.year, status: "done", completed_at: Date.today)
# user_service2 = UserService.create!(profile: profile, service: service2, due_date: Date.today + 1.year, status: "undone", completed_at: Date.today)
puts "Created #{User.count} users, #{Profile.count} profiles and #{UserService.count} user services"
# insurances seed:
HEALTH_INSURANCE_PROVIDERS = [
  "AOK",
  "Allianz Private Krankenversicherung",
  "ARAG Krankenversicherung",
  "AXA Krankenversicherung",
  "BARMER",
  "Barmenia Krankenversicherung",
  "Betriebskrankenkasse",
  "Concordia",
  "Continentale Krankenversicherung",
  "DAK-Gesundheit",
  "Debeka",
  "DKV Deutsche Krankenversicherung",
  "Envivas",
  "ERGO Krankenversicherung",
  "Gothaer Krankenversicherung",
  "Hallesche Krankenversicherung",
  "HanseMerkur",
  "HEK Hanseatische Krankenkasse",
  "hkk Handelskrankenkasse",
  "HUK-COBURG Krankenversicherung",
  "IKK",
  "Inter Krankenversicherung",
  "KKH",
  "KNAPPSCHAFT",
  "Landwirtschaftliche Krankenkasse (SVLFG)",
  "LVM Krankenversicherung",
  "Nürnberger Krankenversicherung",
  "ottonova",
  "PAX Familienfürsorge",
  "R+V Krankenversicherung",
  "SDK Süddeutsche Krankenversicherung",
  "Signal Iduna Krankenversicherung",
  "Techniker Krankenkasse (TK)",
  "UKV Union Krankenversicherung",
  "Württembergische Krankenversicherung"
]

HealthInsurance.destroy_all

HEALTH_INSURANCE_PROVIDERS.each do |name|
  HealthInsurance.find_or_create_by!(name: name)
  puts " → #{name}"
end

User.find_each do |user|
  Notification.find_or_create_by!(user: user) do |n|
    n.enabled = true
    n.sms     = false
    n.push    = true
    n.email   = true
  end
end

puts "Seeding Services..."

services = [
  # --- General Checkups (All Genders) ---
  {
    name: "Dental Checkup",
    description: "Examination of teeth and gums. Annual tartar removal covered by insurance. Don’t forget your bonus booklet!",
    category: "checkup",
    gender_restriction: "any",
    recommended_start_age: 18,
    frequency_months: 6
  },
  {
    name: "General Health Check-up (One-time)",
    description: "One-time general health check (blood, urine, medical history) for early detection of cardiovascular disease and diabetes.",
    category: "checkup",
    gender_restriction: "any",
    recommended_start_age: 18,
    recommended_end_age: 34,
    frequency_months: nil
  },
  {
    name: "General Health Check-up (Over 35)",
    description: "Comprehensive health check every 3 years. Includes blood values (cholesterol, glucose), urine analysis, and medical history. One-time hepatitis screening included.",
    category: "checkup",
    gender_restriction: "any",
    recommended_start_age: 35,
    frequency_months: 36
  },
  {
    name: "Skin Cancer Screening",
    description: "Full-body visual examination of the skin for changes (moles, melanomas) by a dermatologist or trained GP.",
    category: "checkup",
    gender_restriction: "any",
    recommended_start_age: 35,
    frequency_months: 24
  },

  # --- Checkups for Women ---
  {
    name: "Gynecological Cancer Screening",
    description: "Examination of female reproductive organs and cervical smear (Pap test) for early detection of cervical cancer.",
    category: "checkup",
    gender_restriction: "female",
    recommended_start_age: 20,
    frequency_months: 12
  },
  {
    name: "Breast Cancer Screening (Clinical Exam)",
    description: "Clinical breast exam including palpation of breasts and regional lymph nodes by a gynecologist.",
    category: "checkup",
    gender_restriction: "female",
    recommended_start_age: 30,
    frequency_months: 12
  },
  {
    name: "Co-testing (Pap + HPV)",
    description: "Combined screening: cervical smear for cellular changes and HPV test. Replaces the stand-alone Pap test every 3 years.",
    category: "checkup",
    gender_restriction: "female",
    recommended_start_age: 35,
    frequency_months: 36
  },
  {
    name: "Mammography Screening",
    description: "X-ray examination of the breasts for early detection of breast cancer. Invitation is usually sent automatically by mail.",
    category: "checkup",
    gender_restriction: "female",
    recommended_start_age: 50,
    recommended_end_age: 75,
    frequency_months: 24
  },

  # --- Checkups for Men ---
  {
    name: "Men’s Cancer Screening (Prostate/Genitals)",
    description: "Examination of external genitalia, rectal prostate palpation, and lymph node assessment.",
    category: "checkup",
    gender_restriction: "male",
    recommended_start_age: 45,
    frequency_months: 12
  },
  {
    name: "Abdominal Aortic Aneurysm Screening",
    description: "Ultrasound examination of the abdominal aorta to detect dangerous aneurysms.",
    category: "checkup",
    gender_restriction: "male",
    recommended_start_age: 65,
    frequency_months: nil
  },

  # --- Colorectal Cancer Screening ---
  {
    name: "Colorectal Cancer Screening (Stool Test)",
    description: "Immunological test for occult (non-visible) blood in stool.",
    category: "checkup",
    gender_restriction: "any",
    recommended_start_age: 50,
    recommended_end_age: 54,
    frequency_months: 12
  },
  {
    name: "Colonoscopy Screening (Men)",
    description: "Full colonoscopy. Alternative: stool test every 2 years.",
    category: "checkup",
    gender_restriction: "male",
    recommended_start_age: 50,
    frequency_months: 120
  },
  {
    name: "Colonoscopy Screening (Women)",
    description: "Full colonoscopy. Alternative: stool test every 2 years.",
    category: "checkup",
    gender_restriction: "female",
    recommended_start_age: 55,
    frequency_months: 120
  },

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

services.each do |svc|
  Service.find_or_create_by!(name: svc[:name]) do |r|
    r.description = svc[:description]
    r.category = svc[:category]
    r.gender_restriction = svc[:gender_restriction]
    r.recommended_start_age = svc[:recommended_start_age]
    r.recommended_end_age = svc[:recommended_end_age]
    r.frequency_months = svc[:frequency_months]
  end
end

puts "Seeded #{Service.count} services."
