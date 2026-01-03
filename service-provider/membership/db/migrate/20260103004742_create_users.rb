class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :id_provider_user_id
      t.string :email
      t.string :name

      t.timestamps
    end
    add_index :users, :id_provider_user_id, unique: true
  end
end
