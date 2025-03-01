class UpdateGemDataJob < ApplicationJob
  queue_as :default

  # Add retry for transient errors, with exponential backoff
  retry_on StandardError, wait: :exponentially_longer, attempts: 3, jitter: 0.15

  # Don't retry for non-existent gems
  discard_on Gems::NotFound

  def perform(app_gem_id)
    app_gem = AppGem.find_by(id: app_gem_id)
    return unless app_gem.present?

    gem_data = Gems.info(app_gem.name)
    
    # Validate the response
    return if gem_data.blank? || !gem_data.is_a?(Hash)
    
    # Update the gem with data as-is from the API
    app_gem.update(details: gem_data)
  end
end
