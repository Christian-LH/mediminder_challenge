class Service < ApplicationRecord
  has_many :user_services
  has_many :profiles, through: :user_services
end
