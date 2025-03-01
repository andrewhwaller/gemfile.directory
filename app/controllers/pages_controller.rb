class PagesController < ApplicationController
  def top_gems
    # Top gems are the gems that exist the most number of times in GemfileAppGem
    @gems = AppGem.select("app_gems.*, COUNT(gemfile_app_gems.app_gem_id) as count")
                  .joins(:gemfile_app_gems)
                  .group("app_gems.id")
                  .order("count DESC")
                  .limit(25)
  end
end
