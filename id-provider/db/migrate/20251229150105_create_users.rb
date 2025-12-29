class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :sub, null: false, index: { unique: true }
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :name
      t.string :given_name
      t.string :family_name
      t.string :picture
      t.boolean :email_verified, default: false
      t.timestamps
    end
  end
end