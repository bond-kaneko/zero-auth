class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.jsonb :permissions, null: false, default: {}

      t.timestamps
    end

    add_index :roles, [ :organization_id, :name ], unique: true
  end
end
