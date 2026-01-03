class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: false do |t|
      t.string :id_provider_user_id, null: false, primary_key: true
      t.string :email
      t.string :name

      t.timestamps
    end
  end
end
