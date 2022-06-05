class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :session_token
      t.string :name
      t.string :user_name
      t.string :email
      t.string :password_digest
      t.string :image
      t.string :biography
      t.string :activation_digest
      t.boolean :activated, default: false
      t.datetime :activated_at
      t.boolean :admin, default: false
      t.timestamps
    end
    add_index :users, :session_token
    add_index :users, :name
    add_index :users, :user_name
    add_index :users, :email
  end
end
