class MoviesController < ApplicationController
  def index
    @movies = Movie.all.sort
  end

  def show
    @movie = Movie.find(params[:id])
  end

  def download
    movie = Movie.find(params[:id])

    if movie.nil?
      render :nothing => true, :status => 404
    else
      send_file movie.file.to_s, :stream => true, :buffer_size => 32.kilobytes
    end
  end
end
