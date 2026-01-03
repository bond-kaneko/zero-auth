class ChangeUserIdTypeInMemberships < ActiveRecord::Migration[8.1]
  def up
    # Remove indexes
    remove_index :memberships, :user_id
    remove_index :memberships, [ :user_id, :role_id ]

    # Change column type from uuid to string
    change_column :memberships, :user_id, :string, null: false

    # Re-add indexes
    add_index :memberships, :user_id
    add_index :memberships, [ :user_id, :role_id ], unique: true
  end

  def down
    # Remove indexes
    remove_index :memberships, :user_id
    remove_index :memberships, [ :user_id, :role_id ]

    # Change column type back to uuid
    change_column :memberships, :user_id, :uuid, null: false, using: 'user_id::uuid'

    # Re-add indexes
    add_index :memberships, :user_id
    add_index :memberships, [ :user_id, :role_id ], unique: true
  end
end
