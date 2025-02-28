class CreateFavorites < ActiveRecord::Migration[7.2]
  def change
    create_table :favorites, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.string :user_id, null: false
      t.string :favoritable_type, null: false
      t.string :favoritable_id, null: false

      t.timestamps
    end

    add_foreign_key :favorites, :users
    add_index :favorites, :user_id
    add_index :favorites, [ :favoritable_type, :favoritable_id ]
  end
end
