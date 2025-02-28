require "securerandom"

module IdGenerator
  def self.uuid
    SecureRandom.uuid
  end
end
