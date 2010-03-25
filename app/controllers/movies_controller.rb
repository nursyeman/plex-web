class MoviesController < ApplicationController
  include MoviesHelper

  def index
    respond_to do |format|
      format.html do
        redirect_to root_url
      end
      format.json do
        render :json => Movie.all.sort.map {|movie| movie_data_for_view(movie)}
      end
    end
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
