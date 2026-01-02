class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships, id: :uuid do |t|
      t.uuid :user_id, null: false # References id-provider users table
      t.references :role, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :memberships, :user_id
    add_index :memberships, [:user_id, :role_id], unique: true
  end
end
