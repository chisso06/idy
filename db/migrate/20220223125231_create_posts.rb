class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.belongs_to :user, dependent: :destroy
      t.timestamps
    end
    add_foreign_key :posts, :users, on_delete: :cascade
  end
end
