# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleasing the database ..."
UserService.destroy_all
Profile.destroy_all
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
