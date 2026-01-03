class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.uuid :user_id
      t.string :email
      t.string :name

      t.timestamps
    end
    add_index :users, :user_id, unique: true
  end
end
