class CreateUserServices < ActiveRecord::Migration[7.1]
  def change
    create_table :user_services do |t|
      t.references :user, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.date :due_date
      t.string :status
      t.datetime :completed_at

      t.timestamps
    end
  end
end
