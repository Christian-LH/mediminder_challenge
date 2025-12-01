class HealthInsurance < ApplicationRecord
  has_many :user_insurances
  has_many :users, through: :user_insurances

  has_many :insurance_coverages
  has_many :services, through: :insurance_coverages
end
