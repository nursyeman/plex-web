class Thumbnail
  SIZES = {
    :small => 100,
    :large => 200
  }

  attr_accessor :movie

  def initialize(movie)
    self.movie = movie
  end

  def default
    @default ||= self.class.strategy.get_thumbnail(movie)
  end

  def small
    self.of_size(:small)
  end

  def large
    self.of_size(:large)
  end

  def of_size(size)
    return nil unless width = SIZES[size.to_sym]

    name = File.basename(default, '.*')
    dest = "#{RAILS_ROOT}/tmp/thumbnails/#{size}/#{name[0,1]}/#{name}.jpg"

    if not File.exist?(dest)
      FileUtils.mkdir_p(File.dirname(dest))
      system "sips", default, '--resampleWidth', width.to_s, '--out', dest
    end

    return dest
  end

  def exist?
    default && File.exist?(default)
  end

  def [](size)
    raise ArgumentError, "no thumbnail size #{size.inspect}" unless respond_to?(size)
    __send__(size)
  end

  def to_s
    default
  end

  class <<self
    attr_accessor :strategy
  end
end