# frozen_string_literal: true

class CreateUserConsents < ActiveRecord::Migration[7.1]
  def change
    create_table :user_consents do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.text :scopes
      t.datetime :expires_at

      t.timestamps
    end
  end
end
