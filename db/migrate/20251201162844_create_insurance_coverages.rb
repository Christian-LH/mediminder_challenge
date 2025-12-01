class CreateInsuranceCoverages < ActiveRecord::Migration[7.1]
  def change
    create_table :insurance_coverages do |t|
      t.references :health_insurance, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.boolean :covered

      t.timestamps
    end
  end
end
