class CreateRefreshTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.references :access_token, null: true, foreign_key: true
      t.string :token, null: false, index: { unique: true }
      t.text :scopes, array: true, default: []
      t.datetime :expires_at, null: false
      t.boolean :revoked, default: false
      t.datetime :revoked_at
      t.timestamps
    end
    
    add_index :refresh_tokens, :token
  end
end