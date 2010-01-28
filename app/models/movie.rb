class Movie < ActiveRecord::Base
  set_table_name "movie"
  set_primary_key "idMovie"

  belongs_to :file, :class_name => 'MediaFile', :foreign_key => 'idFile'

  def title
    c00
  end

  def title=(title)
    self.c00 = title
  end

  def long_description
    c01
  end

  def long_description=(long_description)
    self.c01 = long_description
  end

  def short_description
    c02
  end

  def short_description=(short_description)
    self.c02 = short_description
  end

  def year
    c07
  end

  def year=(year)
    self.c07 = year
  end

  def imdb_key
    c09
  end

  def imdb_key=(imdb_key)
    self.c09 = imdb_key
  end

  def sort_title
    title.sub(/\A(The|A|An|Le|El)\s+/i, '').downcase
  end

  def <=>(other)
    self.sort_title <=> other.sort_title
  end

  def thumbnail
    @thumbnail ||= self.class.thumbnail_strategy.get_thumbnail(self)
  end

  class <<self
    attr_accessor :thumbnail_strategy
  end
end