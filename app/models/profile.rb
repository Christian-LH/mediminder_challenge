class Profile < ApplicationRecord
  belongs_to :user
  has_many :user_services
  has_many :services, through: :user_services

  has_many_attached :vaccination_passes, service: :local
  validates :gender, presence: true
  validates :birthday, presence: true
  validates :user_name, presence: true

  def age
    today = Date.today
    age = today.year - birthday.year
    age -= 1 if today < birthday + age.years
    age
  end

  def mark_vaccinations_as_completed!(vaccinations)
    processed = 0
    Array(vaccinations).each do |vacc|
      next unless vacc && vacc[:name].present?

      service = Service.find_by(category: "vaccination", name: vacc[:name])

      # create service if it doesn't exist (imported from vaccination pass)
      unless service
        service = Service.create!(category: "vaccination", name: vacc[:name], description: (vacc[:description] || "Imported from vaccination pass"))
      end

      us = user_services.find_or_initialize_by(service: service)
      us.completed_at = vacc[:date]
      us.status = "done"
      us.due_date ||= (vacc[:date] || Date.today)
      us.save!
      processed += 1
    end

    processed
  end
end
