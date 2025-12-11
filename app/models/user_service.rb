class UserService < ApplicationRecord
  belongs_to :service
  belongs_to :profile

  # Order the pending services by due date ascending
  scope :ordered_for_index, -> {
    order(Arel.sql("CASE WHEN status = 'pending' THEN 0 ELSE 1 END, COALESCE(due_date, '9999-12-31') ASC"))
  }
end
