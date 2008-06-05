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

  should 'give error when there is no partial for class' do
    assert_raises ArgumentError do
      partial_for_class(nil)
    end
  end

  should 'generate link to stylesheet' do
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', 'stylesheets', 'something.css')).returns(true)
    expects(:filename_for_stylesheet).with('something', nil).returns('/stylesheets/something.css')
    assert_match '@import url(/stylesheets/something.css)', stylesheet_import('something')
  end

  should 'not generate link to unexisting stylesheet' do
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', 'stylesheets', 'something.css')).returns(false)
    expects(:filename_for_stylesheet).with('something', nil).returns('/stylesheets/something.css')
    assert_no_match %r{@import url(/stylesheets/something.css)}, stylesheet_import('something')
  end

  should 'translate date' do
    date = mock
    expects(:_).with('%d %B %Y').returns('the date')
    date.expects(:strftime).with('the date').returns('translated date')
    assert_equal 'translated date', show_date(date)
  end

  should 'handle nil dates' do
    assert_equal '', show_date(nil)
  end

  should 'translate time' do
    time = mock
    expects(:_).with('%d %B %Y, %H:%m').returns('the time')
    time.expects(:strftime).with('the time').returns('translated time')
    assert_equal 'translated time', show_time(time)
  end

  should 'handle nil time' do
    assert_equal '', show_time(nil)
  end

  should 'append with-text class and keep existing classes' do
    expects(:button_without_text).with('type', 'label', 'url', { :class => 'with-text class1'})
    button('type', 'label', 'url', { :class => 'class1' })
  end

  should 'generate correct link to category' do
    cat = mock
    cat.expects(:path).returns('my-category/my-subcatagory')
    cat.expects(:full_name).returns('category name')

    result = "/cat/my-category/my-subcatagory"
    expects(:link_to).with('category name', :controller => 'search', :action => 'category_index', :category_path => ['my-category', 'my-subcatagory']).returns(result)
    assert_same result, link_to_category(cat)
  end

  should 'get current theme' do
    assert_equal 'default', current_theme()
  end

  should 'nil theme option when no exists theme' do
    File.expects(:exists?).returns(false)
    assert_nil theme_option()
  end

  should 'not nil to ecosol theme option' do
    expects(:current_theme).returns('ecosol')
    assert_not_nil theme_option()
  end

  should 'not nil to zen3 theme option' do
    expects(:current_theme).returns('zen3')
    assert_not_nil theme_option()
  end

  should 'nil javascript theme when no exists theme' do
    File.expects(:exists?).returns(false)
    assert_nil theme_javascript
  end

  should 'not nil javascript theme to ecosol theme' do
    expects(:current_theme).returns('ecosol')
    assert_not_nil theme_javascript
  end

  should 'generate period with two dates' do
    date1 = mock
    expects(:show_date).with(date1).returns('XXX')
    date2 = mock
    expects(:show_date).with(date2).returns('YYY')
    expects(:_).with('from %s to %s').returns('from %s to %s')
    assert_equal 'from XXX to YYY', show_period(date1, date2)
  end

  should 'generate period with two equal dates' do
    date1 = mock
    expects(:show_date).with(date1).returns('XXX')
    assert_equal 'XXX', show_period(date1, date1)
  end

  should 'generate period with one date only' do
    date1 = mock
    expects(:show_date).with(date1).returns('XXX')
    assert_equal 'XXX', show_period(date1)
  end


  protected

  def content_tag(tag, content, options)
    content.strip
  end

end
