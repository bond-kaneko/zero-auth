class AddClientTypeColumnToClients < ActiveRecord::Migration[8.1]
  def change
    add_column :clients, :client_type, :string, default: "authorization_code", null: false
    add_index :clients, :client_type
  end
end
