require File.dirname(__FILE__) + '/test_helper'

class TemplateTest < Test::Unit::TestCase

  include Design

  def test_should_read_title
    assert_equal 'Some title', Template.new('test', { 'title' => 'Some title' }).title
  end

  def test_should_get_name
    assert_equal 'default', Template.find('default').name
  end

  def test_should_get_number_of_boxes
    assert_equal 3, Template.new('test', { 'number_of_boxes' => 3}).number_of_boxes
  end

end
