class UserService < ApplicationRecord
  belongs_to :service
  belongs_to :profile

  # Order the pending services by due date ascending
  scope :ordered_for_index, -> {
    order(due_date: :asc)
  }

  # Order the done services by completed date descending
  scope :ordered_for_history, -> {
    order(completed_at: :desc)
  }
end
