class UpdateGemDataJob < ApplicationJob
  queue_as :default
  
  # Add retry for transient errors, with exponential backoff
  retry_on StandardError, wait: :exponentially_longer, attempts: 3, jitter: 0.15
  
  # Don't retry for non-existent gems or other specific errors
  discard_on Gems::NotFound

  def perform(app_gem_id)
    app_gem = AppGem.find_by(id: app_gem_id)

    if app_gem.present?
      begin
        # Log the attempt to fetch data
        Rails.logger.info("Fetching gem data for #{app_gem.name} (ID: #{app_gem.id})")
        
        gem_data = Gems.info(app_gem.name)
        
        # Check if gem_data is valid before trying to access its keys
        if gem_data.blank? || !gem_data.is_a?(Hash)
          Rails.logger.error("Invalid gem data received for #{app_gem.name}: #{gem_data.inspect}")
          return
        end
        
        # Now it's safe to log the keys since we've verified it's a hash
        Rails.logger.info("Successfully fetched data for #{app_gem.name}: #{gem_data.keys.join(', ')}")
        
        # Add timestamps to track when the data was last fetched
        gem_data['_fetched_at'] = Time.current.iso8601
        
        # Update the app_gem with the fetched data
        if app_gem.update(details: gem_data)
          Rails.logger.info("Successfully updated details for #{app_gem.name}")
        else
          Rails.logger.error("Failed to update details for #{app_gem.name}: #{app_gem.errors.full_messages.join(', ')}")
          # Notify error monitoring service if available
          Honeybadger.notify("Failed to update gem details", 
                            context: { 
                              gem_name: app_gem.name, 
                              gem_id: app_gem.id,
                              errors: app_gem.errors.full_messages
                            }) if defined?(Honeybadger)
        end
      rescue Gems::NotFound => e
        Rails.logger.warn("Gem not found: #{app_gem.name} - #{e.message}")
        # Mark this gem as not found to avoid repeated lookups
        app_gem.update(details: { error: 'not_found', message: e.message, _fetched_at: Time.current.iso8601 })
        raise # Re-raise to trigger the discard_on
      rescue => e
        # Catch all other exceptions to prevent the job from silently failing
        Rails.logger.error("Error fetching gem data for #{app_gem.name}: #{e.class} - #{e.message}")
        Rails.logger.error(e.backtrace.join("\n")) if e.backtrace
        
        # Notify error monitoring service if available
        Honeybadger.notify(e, 
                          context: { 
                            gem_name: app_gem.name, 
                            gem_id: app_gem.id
                          }) if defined?(Honeybadger)
        
        # Store the error in the details to avoid repeated failures if it's a permanent error
        if defined?(e.response) && e.response.is_a?(Net::HTTPResponse) && e.response.code.to_i == 429
          app_gem.update(details: { 
            error: 'rate_limited', 
            message: e.message, 
            _fetched_at: Time.current.iso8601,
            _retry_after: (Time.current + 1.hour).iso8601 # Back off for an hour on rate limiting
          })
        end
        
        raise # Re-raise to trigger the retry_on
      end
    else
      Rails.logger.warn("AppGem not found with ID: #{app_gem_id}")
    end
  end
end
