class EnableUuid < ActiveRecord::Migration[7.2]
  def change
    # Using Ruby's SecureRandom.uuid instead of database-specific UUID generation
  end
end
