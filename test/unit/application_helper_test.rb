require File.dirname(__FILE__) + '/../test_helper'

class ApplicationHelperTest < Test::Unit::TestCase

  include ApplicationHelper

  should 'calculate correctly partial for object' do
    self.stubs(:params).returns({:controller => 'test'})

    File.expects(:exists?).with("#{RAILS_ROOT}/app/views/test/_float.rhtml").returns(false)
    File.expects(:exists?).with("#{RAILS_ROOT}/app/views/test/_numeric.rhtml").returns(true).times(2)
    File.expects(:exists?).with("#{RAILS_ROOT}/app/views/test/_runtime_error.rhtml").returns(true).at_least_once

    assert_equal 'numeric', partial_for_class(Float)
    assert_equal 'numeric', partial_for_class(Numeric)
    assert_equal 'runtime_error', partial_for_class(RuntimeError)
  end

  should 'generate link to stylesheet' do
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', 'stylesheets', 'something.css')).returns(true)
    expects(:filename_for_stylesheet).with('something', nil).returns('/stylesheets/something.css')
    assert_match '@import url(/stylesheets/something.css)', stylesheet_import('something')
  end

  should 'not generate link to unexisting stylesheet' do
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', 'stylesheets', 'something.css')).returns(false)
    expects(:filename_for_stylesheet).with('something', nil).returns('/stylesheets/something.css')
    assert_equal '', stylesheet_import('something')
  end

  protected

  def content_tag(tag, content, options)
    content.strip
  end

end
