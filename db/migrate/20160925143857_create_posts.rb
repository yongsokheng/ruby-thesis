class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.text :content
      t.string :image
      t.integer :status
      t.references :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
