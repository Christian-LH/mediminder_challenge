class UserInsurance < ApplicationRecord
  belongs_to :user
  belongs_to :health_insurance
end
