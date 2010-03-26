class PostersController < ApplicationController
  def show
    movie = Movie.find(params[:movie_id])

    if movie.poster.exist?
      expires_in 10.years, :public => true
      # send_file movie.poster[params[:id]],
      #   :filename => movie.file.basename('.*')+'.jpg',
      #   :type => 'image/jpeg',
      #   :disposition => 'inline'
      send_data File.read(movie.poster[params[:id]]),
        :filename => movie.file.basename('.*')+'.jpg',
        :type => 'image/jpeg',
        :disposition => 'inline'
    else
      expires_now
      redirect_to '/images/unknown-movie.png'
    end
  end
end
