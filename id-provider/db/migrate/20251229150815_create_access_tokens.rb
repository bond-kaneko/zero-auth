class CreateAccessTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :access_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.references :authorization_code, null: true, foreign_key: true
      t.string :token, null: false, index: { unique: true }
      t.text :scopes, array: true, default: []
      t.string :token_type, default: 'Bearer'
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end