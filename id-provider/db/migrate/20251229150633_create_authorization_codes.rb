class CreateAuthorizationCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :authorization_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.string :code, null: false, index: { unique: true }
      t.text :redirect_uri, null: false
      t.text :scopes, array: true, default: []
      t.string :nonce
      t.string :code_challenge
      t.string :code_challenge_method
      t.datetime :expires_at, null: false
      t.boolean :used, default: false
      t.datetime :used_at
      t.timestamps
    end
    
    add_index :authorization_codes, [:code, :used]
  end
end