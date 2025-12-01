class Service < ApplicationRecord
  has_many :user_services
  has_many :users, through: :user_services

  has_many :insurance_coverages
  has_many :health_insurances, through: :insurance_coverages
end
