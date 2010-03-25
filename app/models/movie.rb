class Movie < ActiveRecord::Base
  set_table_name "movie"
  set_primary_key "idMovie"

  belongs_to :file, :class_name => 'MediaFile', :foreign_key => 'idFile'

  COLUMNS = [
    :title,           # string
    :plot,            # string
    :outline,         # string
    :tagline,         # string
    :votes,           # string
    :rating,          # float
    :credits,         # string
    :year,            # int
    :thumburl,        # string
    :ident,           # string
    :playcount,       # int
    :runtime,         # string
    :mpaa,            # string
    :top250,          # int
    :genre,           # string
    :director,        # string
    :original_title,  # string
    :thumburl_spoof,  # string
    :studios,         # string
    :trailer,         # string
    :fanart           # string
  ].freeze

  COLUMNS.each_with_index do |column, i|
    class_eval <<-RUBY
    def #{column}
      c#{sprintf("%02d", i)}
    end

    def #{column}=(value)
      self.c#{sprintf("%02d", i)} = value
    end
    RUBY
  end

  def sort_title
    title.sub(/\A(The|A|An|Le|El)\s+/i, '').downcase
  end

  def <=>(other)
    self.sort_title <=> other.sort_title
  end

  def poster
    @poster ||= Thumbnail.new(self, :poster)
  end

  def fanart
    @fanart ||= Thumbnail.new(self, :fanart)
  end

  def to_json(*args)
    (COLUMNS + [:id, :sort_title, :poster, :fanart]).inject({}) do |hash, key|
      hash.merge(key => __send__(key))
    end.to_json(*args)
  end
end