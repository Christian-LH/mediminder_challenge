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
service1 = Service.create(name: "Flu Shot", description: "the vacciantion against the influenza virus", gender_restriction: "male", recommended_start_age: 18, recommended_end_age: 65)
service2 = Service.create(name: "Prophylaxis", description: "deep cleaning of the teeth", gender_restriction: "male", recommended_start_age: 18, recommended_end_age: 65)


puts "Created #{Service.count} services"
puts "Creating a user with profile and user_service ..."
user = User.create!(email: "bob@gmail.com", password: "Password123")
profile = Profile.create!(user: user, gender: "male", birthday: Date.new(2002, 3, 7))
user_service1 = UserService.create!(profile: profile, service: service1, due_date: Date.today + 1.year, status: "done", completed_at: Date.today)
user_service2 = UserService.create!(profile: profile, service: service2, due_date: Date.today + 1.year, status: "undone", completed_at: Date.today)
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
    name: "Zahnvorsorge",
    description: "Kontrolle der Zähne und des Zahnfleischs. Einmal jährlich Zahnsteinentfernung als Kassenleistung. Bonusheft nicht vergessen!",
    category: "checkup",
    gender_restriction: "any",
    recommended_start_age: 18,
    frequency_months: 6
  },
  {
    name: "Gesundheits-Check-up (Einmalig)",
    description: "Einmaliger allgemeiner Gesundheits-Check (Blut, Urin, Anamnese) zur Früherkennung von Herz-Kreislauf-Erkrankungen und Diabetes.",
    category: "checkup",
    gender_restriction: "any",
    recommended_start_age: 18,
    recommended_end_age: 34,
    frequency_months: nil
  },
  {
    name: "Gesundheits-Check-up (Check-up 35)",
    description: "Umfassender Gesundheits-Check alle 3 Jahre. Inklusive Blutwerte (Cholesterin, Zucker), Urin und Anamnese. Einmalig inklusive Hepatitis-Screening.",
    category: "checkup",
    gender_restriction: "any",
    recommended_start_age: 35,
    frequency_months: 36
  },
  {
    name: "Hautkrebs-Screening",
    description: "Visuelle Ganzkörperuntersuchung der Haut auf Veränderungen (Muttermale, Melanome) durch einen Dermatologen oder qualifizierten Hausarzt.",
    category: "checkup",
    gender_restriction: "any",
    recommended_start_age: 35,
    frequency_months: 24
  },

  # --- Checkups for Women ---
  {
    name: "Gynäkologische Krebsvorsorge",
    description: "Untersuchung der Geschlechtsorgane und Abstrich vom Gebärmutterhals (Pap-Test) zur Früherkennung von Zervixkarzinomen.",
    category: "checkup",
    gender_restriction: "female",
    recommended_start_age: 20,
    frequency_months: 12
  },
  {
    name: "Brustkrebsvorsorge (Tastuntersuchung)",
    description: "Abtasten der Brüste und der örtlichen Lymphknoten durch den Frauenarzt.",
    category: "checkup",
    gender_restriction: "female",
    recommended_start_age: 30,
    frequency_months: 12
  },
  {
    name: "Ko-Test (Pap + HPV)",
    description: "Kombinations-Screening: Abstrich auf Zellveränderungen und Test auf Humane Papillomviren (HPV). Ersetzt alle 3 Jahre den einfachen Pap-Test.",
    category: "checkup",
    gender_restriction: "female",
    recommended_start_age: 35,
    frequency_months: 36
  },
  {
    name: "Mammographie-Screening",
    description: "Röntgenuntersuchung der Brust zur Früherkennung von Brustkrebs. Einladung erfolgt meist automatisch per Post.",
    category: "checkup",
    gender_restriction: "female",
    recommended_start_age: 50,
    recommended_end_age: 75,
    frequency_months: 24
  },

  # --- Checkups for Men ---
  {
    name: "Krebsvorsorge Männer (Prostata/Genitalien)",
    description: "Untersuchung der äußeren Geschlechtsorgane, Abtasten der Prostata vom Enddarm aus und Kontrolle der Lymphknoten.",
    category: "checkup",
    gender_restriction: "male",
    recommended_start_age: 45,
    frequency_months: 12
  },
  {
    name: "Bauchaortenaneurysma-Screening",
    description: "Ultraschalluntersuchung der Bauchschlagader zur Früherkennung von Aussackungen (Aneurysmen).",
    category: "checkup",
    gender_restriction: "male",
    recommended_start_age: 65,
    frequency_months: nil
  },

  # --- Colorectal Cancer (Darmkrebs) - Complex Logic Simplified ---
  {
    name: "Darmkrebsvorsorge (Stuhltest)",
    description: "Immunologischer Test auf okkultes (nicht sichtbares) Blut im Stuhl.",
    category: "checkup",
    gender_restriction: "any",
    recommended_start_age: 50,
    recommended_end_age: 54,
    frequency_months: 12
  },
  {
    name: "Darmkrebsvorsorge (Darmspiegelung - Männer)",
    description: "Große Darmspiegelung (Koloskopie). Alternativ: Stuhltest alle 2 Jahre.",
    category: "checkup",
    gender_restriction: "male",
    recommended_start_age: 50,
    frequency_months: 120
  },
  {
    name: "Darmkrebsvorsorge (Darmspiegelung - Frauen)",
    description: "Große Darmspiegelung (Koloskopie). Alternativ: Stuhltest alle 2 Jahre.",
    category: "checkup",
    gender_restriction: "female",
    recommended_start_age: 55,
    frequency_months: 120
  },

  # --- Vaccinations (STIKO Recommendations for Adults) ---
  {
    name: "Tetanus & Diphtherie (Auffrischung)",
    description: "Regelmäßige Auffrischung alle 10 Jahre. Mindestens einmal im Erwachsenenalter sollte Keuchhusten (Pertussis) mitgeimpft werden (Tdap).",
    category: "vaccination",
    gender_restriction: "any",
    recommended_start_age: 18,
    frequency_months: 120
  },
  {
    name: "Masern-Impfung",
    description: "Einmalige Impfung für alle nach 1970 Geborenen mit unklarem Impfstatus oder nur einer Impfung in der Kindheit.",
    category: "vaccination",
    gender_restriction: "any",
    recommended_start_age: 18,
    frequency_months: nil
  },
  {
    name: "Grippe-Impfung (Influenza)",
    description: "Jährliche Impfung im Herbst (Okt/Nov). Standardempfehlung ab 60 Jahren, für Schwangere und chronisch Kranke.",
    category: "vaccination",
    gender_restriction: "any",
    recommended_start_age: 60,
    frequency_months: 12
  },
  {
    name: "Pneumokokken-Impfung",
    description: "Schutz vor Lungenentzündungen. Standardimpfung ab 60 Jahren.",
    category: "vaccination",
    gender_restriction: "any",
    recommended_start_age: 60,
    frequency_months: nil
  },
  {
    name: "Gürtelrose (Herpes Zoster)",
    description: "Zwei Impfdosen im Abstand von 2 bis 6 Monaten. Standard ab 60 Jahren (ab 50 bei Grunderkrankungen).",
    category: "vaccination",
    gender_restriction: "any",
    recommended_start_age: 60,
    frequency_months: nil
  },
  {
    name: "Corona-Schutzimpfung (COVID-19)",
    description: "Jährliche Auffrischung im Herbst für Personen ab 60 Jahren und Risikogruppen. Basisimmunität (3 Kontakte) sollte jeder Erwachsene haben.",
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
