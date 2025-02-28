class My::FavoritesController < ApplicationController
  def index
    if current_user.blank?
      redirect_to root_path, notice: "You must be logged in to view your favorites"
    else
      @favorite_gemfiles = current_user.favorite_gemfiles
    end
  end
end
