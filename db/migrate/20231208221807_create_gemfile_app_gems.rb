class CreateGemfileAppGems < ActiveRecord::Migration[7.2]
  def change
    create_table :gemfile_app_gems, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.string :gemfile_id, null: false
      t.string :app_gem_id, null: false

      t.timestamps
    end

    add_foreign_key :gemfile_app_gems, :gemfiles
    add_foreign_key :gemfile_app_gems, :app_gems
    add_index :gemfile_app_gems, :gemfile_id
    add_index :gemfile_app_gems, :app_gem_id
  end
end
