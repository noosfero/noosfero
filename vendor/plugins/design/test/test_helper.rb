ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
 
require 'test/unit'

# load the database schema for the tests
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
load(File.dirname(__FILE__) + '/schema.rb')
# change the table names for the tests to not touch
Design::Box.set_table_name 'design_test_design_boxes'
[Design::Block, Design::MainBlock].each do |item|
  item.set_table_name 'design_test_design_blocks'
end

# example class to hold some blocks
class DesignTestUser < ActiveRecord::Base
  set_table_name 'design_test_users'

  acts_as_design
end

########################
# test clases below here
########################

class FixedDesignTestController < ActionController::Base

  BOX1 = Design::Box.new
  BOX2 = Design::Box.new
  BOX3 = Design::Box.new

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
