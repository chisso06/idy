class CreateTags < ActiveRecord::Migration[7.0]
  def change
    create_table :tags do |t|
      t.string :tag, unique: true
      t.timestamps
    end
    add_index :tags, :tag
  end
end
