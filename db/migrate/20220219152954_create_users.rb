class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :hashed_id
      t.string :name
      t.string :user_name
      t.string :email
      t.string :password_digest
      t.string :image
      t.string :biography
      t.string :admin, default: 0
      t.timestamps
    end
    add_index :users, :hashed_id
    add_index :users, :name
    add_index :users, :user_name
    add_index :users, :email
  end
end
