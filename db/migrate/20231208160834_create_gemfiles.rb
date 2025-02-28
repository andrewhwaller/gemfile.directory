class CreateGemfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :gemfiles, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.string :user_id, null: false
      t.text :content

      t.timestamps
    end

    add_foreign_key :gemfiles, :users
    add_index :gemfiles, :user_id
  end
end
