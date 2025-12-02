class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.string :gender
      t.date :birthday
      t.string :phone_number
      t.string :user_name
      t.string :field_of_work
      t.string :zip_code
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
