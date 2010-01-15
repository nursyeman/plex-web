require 'spec_helper'

describe Movie do
  describe "with a simple movie title and a year" do
    before do
      @path = '/home/quentin/movies/Fargo (1996).m4v'
      @movie = Movie.new(@path)
    end

    it "can extract a full title including the year" do
      @movie.full_title.should == 'Fargo (1996)'
    end

    it "extracts a simple title from the path name" do
      @movie.title.should == 'Fargo'
    end
  end

  describe "with a title starting with 'The'" do
    before do
      @path = '/home/quentin/movies/The Ring (2002).m4v'
      @movie = Movie.new(@path)
    end

    it "has a sorting title equal to the full title without the 'The'" do
      @movie.sort_title.should == 'Ring (2002)'
    end

    it "has a full title that includes 'The'" do
      @movie.full_title.should == 'The Ring (2002)'
    end

    it "has a title that includes 'The' but without the year" do
      @movie.title.should == 'The Ring'
    end
  end

  describe "with a title containing a colon without whitespace around it" do
    before do
      @path = '/home/quentin/movies/Frost:Nixon (2009).mk4'
      @movie = Movie.new(@path)
    end

    it "has a title with the colon turned into a slash" do
      @movie.title.should == 'Frost/Nixon'
    end

    it "has a sorting title equal to the full title" do
      @movie.sort_title.should == @movie.full_title
    end
  end

  describe "with a title containing a colon with whitespace after it" do
    before do
      @path = '/home/quentin/movies/The Lord of the Rings: The Two Towers (2002).m4v'
      @movie = Movie.new(@path)
    end

    it "has a title with the colon left alone" do
      @movie.title.should == 'The Lord of the Rings: The Two Towers'
    end
  end

  describe "with a title that doesn't contain a year" do
    before do
      @path = '/home/quentin/movies/Office Space.m4v'
      @movie = Movie.new(@path)
    end

    it "has a title equal to the full title" do
      @movie.title.should == @movie.full_title
    end
  end
end