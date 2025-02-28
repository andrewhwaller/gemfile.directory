class CreateAppGems < ActiveRecord::Migration[7.2]
  def change
    create_table :app_gems, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.string :name

      t.timestamps
    end
  end
end
