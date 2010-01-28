class ThumbnailsController < ApplicationController
  def show
    movie = Movie.find(params[:movie_id])

    if movie.thumbnail && File.exist?(movie.thumbnail)
      expires_in 1.day, :public => true
      send_file movie.thumbnail,
        :filename => movie.file.basename('.*')+'.jpg',
        :type => 'application/jpeg',
        :disposition => 'inline'
    else
      expires_now
      redirect_to '/images/unknown-movie.png'
    end
  end
end
