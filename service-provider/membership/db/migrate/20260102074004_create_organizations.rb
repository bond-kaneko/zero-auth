class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    # Enable UUID extension
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :organizations, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :organizations, :slug, unique: true
  end
end
