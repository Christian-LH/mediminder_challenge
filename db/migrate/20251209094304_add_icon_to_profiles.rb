class AddIconToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :icon, :integer
  end
end
