class MediaFile < ActiveRecord::Base
  set_table_name 'files'
  set_primary_key 'idFile'

  belongs_to :path, :class_name => 'MediaPath', :foreign_key => 'idPath'
  has_one :movie, :foreign_key => 'idFile'

  def basename(ext=nil)
    if ext
      File.basename(strFilename, ext)
    else
      strFilename
    end
  end

  def dirname
    path.to_s
  end

  def to_s
    File.join(dirname, basename)
  end
end
