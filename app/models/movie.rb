class Movie
  attr_accessor :title, :full_title, :path

  def initialize(path)
    @path = path
    @full_title = File.basename(path, '.*')
    @title = @full_title.sub(/\s+\(\d{4}\)\Z/, '')
  end

  def sort_title
    full_title.sub(/\A(The|A|An|Le|El)\s+/i, '')
  end

  def <=>(other)
    self.sort_title <=> other.sort_title
  end

  def self.all
    Dir['/Volumes/donovan/Movies/*.{m4v,mp4}'].map { |path| new(path) }
  end
end