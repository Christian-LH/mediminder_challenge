class Service < ApplicationRecord
  has_many :profiles, through: :user_services
end
