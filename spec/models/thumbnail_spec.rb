require 'spec_helper'

describe Thumbnail do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Thumbnail.create!(@valid_attributes)
  end
end
