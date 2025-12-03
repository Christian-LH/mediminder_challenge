class Profile < ApplicationRecord
  belongs_to :user
  has_many :services, through: :user_services
end
