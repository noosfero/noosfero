require File.dirname(__FILE__) + '/../../../test/test_helper'
require 'spec'

class ActiveRecord::TestCase < ActiveSupport::TestCase
  include OrdersCyclePluginFactory
end
