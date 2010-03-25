class Thumbnail
  SIZES = {
    :default => nil,
    :small   => 100,
    :large   => 200
  }

  attr_accessor :movie, :type

  def initialize(movie, type)
    self.movie = movie
    self.type  = type
  end

  def default
    @default ||= self.class.strategy.get_thumbnail(movie, type)
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
    dest = "#{RAILS_ROOT}/tmp/thumbnails/#{type}/#{size}/#{name[0,1]}/#{name}.jpg"

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