class InsuranceCoverage < ApplicationRecord
  belongs_to :health_insurance
  belongs_to :service
end
