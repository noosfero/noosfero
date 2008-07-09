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

  should 'role color for admin role' do
    assert_equal 'blue', role_color(Profile::Roles.admin)
  end
  should 'role color for member role' do
    assert_equal 'green', role_color(Profile::Roles.member)
  end
  should 'role color for moderator role' do
    assert_equal 'gray', role_color(Profile::Roles.moderator)
  end
  should 'default role color' do
    assert_equal 'black', role_color('none')
  end

  should 'rolename for' do
    person = create_user('usertest').person
    community = Community.create!(:name => 'new community', :identifier => 'new-community', :environment => Environment.default)
    community.add_member(person)
    assert_equal 'Profile Member', rolename_for(person, community)
  end

  should 'display categories' do
    category = Category.create!(:name => 'parent category for testing', :environment_id => Environment.default)
    child = Category.create!(:name => 'child category for testing',   :environment => Environment.default, :display_in_menu => true, :parent => category)
    owner = create_user('testuser').person
    @article = owner.articles.create!(:name => 'ytest')
    @article.add_category(category)
    expects(:environment).returns(Environment.default)
    result = select_categories(:article)
    assert_match /parent category/, result
  end

  should 'not display categories if has no child' do
    category = Category.create!(:name => 'parent category for testing', :environment_id => Environment.default)
    owner = create_user('testuser').person
    @article = owner.articles.create!(:name => 'ytest')
    @article.add_category(category)
    expects(:environment).returns(Environment.default)
    result = select_categories(:article)
    assert_no_match /parent category/, result
  end

  protected

  def content_tag(tag, content, options = {})
    content.strip
  end
  def javascript_tag(any)
    ''
  end
  def link_to(label, action, options = {})
    label
  end
  def check_box_tag(name, value = 1, checked = false, options = {})
    name
  end

end
