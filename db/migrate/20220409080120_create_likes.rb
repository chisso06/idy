class CreateLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.belongs_to :user
      t.belongs_to :post
      t.timestamps
    end
    add_foreign_key :likes, :posts, on_delete: :cascade
    add_foreign_key :likes, :users, on_delete: :cascade
  end
end
