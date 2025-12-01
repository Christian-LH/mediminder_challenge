class CreateUserInsurances < ActiveRecord::Migration[7.1]
  def change
    create_table :user_insurances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :health_insurance, null: false, foreign_key: true

      t.timestamps
    end
  end
end
