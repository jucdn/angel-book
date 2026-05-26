class AddShareToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :share_token, :string
    add_column :users, :share_password_digest, :string
    add_index  :users, :share_token, unique: true, where: "share_token IS NOT NULL"
  end
end
