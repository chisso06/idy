class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :content
      t.belongs_to :user, foreign_key: true, dependent: :destroy
      t.belongs_to :post, foreign_key: true, dependent: :destroy
      t.timestamps
    end
  end
end
