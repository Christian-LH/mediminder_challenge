class CreateServices < ActiveRecord::Migration[7.1]
  def change
    create_table :services do |t|
      t.string :name
      t.string :category
      t.text :description
      t.integer :recommended_start_age
      t.integer :recommended_end_age
      t.string :gender_restriction
      t.integer :frequency_months

      t.timestamps
    end
  end
end
