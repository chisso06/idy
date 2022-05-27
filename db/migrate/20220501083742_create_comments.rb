class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :content
      t.belongs_to :user
      t.belongs_to :post
      t.timestamps
    end
    add_foreign_key :comments, :posts, on_delete: :cascade
    add_foreign_key :comments, :users, on_delete: :cascade
  end
end
