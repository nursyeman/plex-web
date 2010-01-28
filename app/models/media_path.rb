class MediaPath < ActiveRecord::Base
  set_table_name 'path'
  set_primary_key 'idPath'

  has_many :files, :class_name => 'MediaFile', :foreign_key => 'idPath'

  def to_s
    strPath
  end
end
