class Profile < ApplicationRecord
  belongs_to :user
  # has_many :user_services
  has_many :services, through: :user_services

  def age
    today = Date.today
    age = today.year - birthday.year
    age -= 1 if today < birthday + age.years
    age
  end
end
