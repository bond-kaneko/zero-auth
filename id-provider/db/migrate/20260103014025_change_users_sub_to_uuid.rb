class ChangeUsersSubToUuid < ActiveRecord::Migration[8.1]
  def up
    # Remove index first
    remove_index :users, :sub

    # Change column type from string to uuid
    change_column :users, :sub, :uuid, using: 'sub::uuid', null: false

    # Add index back
    add_index :users, :sub, unique: true
  end

  def down
    # Remove index first
    remove_index :users, :sub

    # Change column type back to string
    change_column :users, :sub, :string, null: false

    # Add index back
    add_index :users, :sub, unique: true
  end
end
