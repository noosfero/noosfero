ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
 
require 'test/unit'

########################
# test clases below here
########################

class FixedDesignTestController < ActionController::Base

  BOX1 = Box.new
  BOX2 = Box.new
  BOX3 = Box.new

  design :fixed => {
    :template => 'some_template',
    :theme => 'some_theme',
    :icon_theme => 'some_icon_theme',
    :boxes => [ BOX1, BOX2, BOX3 ],
  }
end

class FixedDesignDefaultTestController < ActionController::Base
  design :fixed => true
end

class SampleHolderForTestingProxyDesignHolder
  attr_accessor :template, :theme, :icon_theme, :boxes
end

class ProxyDesignHolderTestController < ActionController::Base
  design :holder => 'sample_object'
  def initialize
    @sample_object = SampleHolderForTestingProxyDesignHolder.new
  end
end

class DesignEditorTestController < ActionController::Base
  design_editor :holder => 'sample_object'
  def initialize
    @sample_object = SampleHolderForTestingProxyDesignHolder.new
  end
end
