class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :enabled
      t.boolean :sms
      t.boolean :push
      t.boolean :email

      t.timestamps
    end
  end
end
