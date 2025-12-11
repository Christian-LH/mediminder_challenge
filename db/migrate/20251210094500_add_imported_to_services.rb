class AddImportedToServices < ActiveRecord::Migration[7.1]
  def change
    add_column :services, :imported, :boolean, default: false, null: false
    add_index :services, :imported
  end
end
