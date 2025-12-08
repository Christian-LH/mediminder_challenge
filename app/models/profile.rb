class Profile < ApplicationRecord
  belongs_to :user
  has_many :user_services
  has_many :services, through: :user_services

  has_one_attached :vaccination_pass

  def age
    today = Date.today
    age = today.year - birthday.year
    age -= 1 if today < birthday + age.years
    age
  end

  def mark_vaccinations_as_completed!(vaccinations)
    vaccinations.each do |vacc|
      service = Service.find(category: "vaccination", name: vacc[:name])
      next unless service

      us = user_service.find_or_initialize_by(service: service)
      us.completed_at = vacc[:date]
      us.status = "done"
      us.save!
    end
  end
end
