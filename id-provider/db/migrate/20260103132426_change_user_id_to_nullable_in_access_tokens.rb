class ChangeUserIdToNullableInAccessTokens < ActiveRecord::Migration[8.1]
  def change
    change_column_null :access_tokens, :user_id, true
  end
end
