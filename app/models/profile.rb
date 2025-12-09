class Profile < ApplicationRecord
  belongs_to :user
  has_many :user_services
  has_many :services, through: :user_services

  validates :gender, presence: true
  validates :birthday, presence: true
  validates :user_name, presence: true

  def age
    today = Date.today
    age = today.year - birthday.year
    age -= 1 if today < birthday + age.years
    age
  end
end
