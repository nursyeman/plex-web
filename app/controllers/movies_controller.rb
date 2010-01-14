class MoviesController < ApplicationController
  def index
    @movies = Movie.all.sort
  end
end
