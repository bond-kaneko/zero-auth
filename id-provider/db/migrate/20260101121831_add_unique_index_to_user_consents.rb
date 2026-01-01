# frozen_string_literal: true

class AddUniqueIndexToUserConsents < ActiveRecord::Migration[7.1]
  def change
    add_index :user_consents, %i[user_id client_id], unique: true
  end
end
