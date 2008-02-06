require File.join(File.dirname(__FILE__), 'test_helper')
require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'controllers', 'doc_controller')

class DocController; def rescue_action(e) raise e end; end

class DocControllerTest < Test::Unit::TestCase

  def setup
    @controller = DocController.new
  end

  def test_index
    @controller.index
    assert_kind_of Array, assigns(:docs)
    assert_kind_of Array, assigns(:errors)
  end


end
