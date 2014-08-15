class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :path
      t.string :filename
      t.string :cam_id
      t.integer :user_id

      t.timestamps
    end
    add_index :photos, [:user_id, :created_at]
  end
end
