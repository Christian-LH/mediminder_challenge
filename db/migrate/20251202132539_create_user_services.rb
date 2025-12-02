class CreateUserServices < ActiveRecord::Migration[7.1]
  def change
    create_table :user_services do |t|
      t.references :service, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.date :due_date
      t.string :status
      t.date :completed_at

      t.timestamps
    end
  end
end
