class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.string :client_id, null: false, index: { unique: true }
      t.string :client_secret, null: false
      t.string :name
      t.text :redirect_uris, array: true, default: []
      t.text :grant_types, array: true, default: []
      t.text :response_types, array: true, default: []
      t.string :client_uri
      t.string :logo_uri
      t.string :policy_uri
      t.string :tos_uri
      t.boolean :active, default: true
      t.timestamps
    end
  end
end