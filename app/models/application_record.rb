class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Use string-based ULID primary keys by default
  self.implicit_order_column = "created_at"

  before_create :set_uuid_primary_key

  private

  def set_uuid_primary_key
    self.id ||= IdGenerator.uuid if self.class.column_names.include?("id")
  end
end
