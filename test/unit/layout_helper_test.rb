require_relative "../test_helper"

class LayoutHelperTest < ActionView::TestCase
  include ApplicationHelper

  should 'append logged-in class in body when user is logged-in' do
    expects(:logged_in?).returns(true)
    expects(:profile).returns(nil).at_least_once
    assert_includes body_classes.split, 'logged-in'
  end

  should 'not append logged-in class when user is not logged-in' do
    expects(:logged_in?).returns(false)
    expects(:profile).returns(nil).at_least_once
    assert_not_includes body_classes.split, 'logged-in'
  end

  should 'add global.css to noosfero_stylesheets if env theme has it' do
    env = fast_create Environment
    env.theme = 'my-theme'
    @plugins = []
    expects(:profile).returns(nil).at_least_once
    expects(:environment).returns(env).at_least_once
    expects(:theme_option).with(:icon_theme).returns(['my-icons']).at_least_once
    expects(:jquery_theme).returns('jquery-nice').at_least_once
    global_css = Rails.root.join "public/designs/themes/#{env.theme}/global.css"
    File.stubs(:exists?).returns(false)
    File.expects(:exists?).with(global_css).returns(true).at_least_once
    css = noosfero_stylesheets
    assert_match /<link [^<]*href="\/designs\/themes\/my-theme\/global.css"/, css
  end

  should 'append javascript files of enabled plugins in noosfero javascripts' do
    plugin1 = Noosfero::Plugin.new
    plugin1.expects(:js_files).returns(['plugin1.js'])
    plugin2 = Noosfero::Plugin.new
    plugin2.expects(:js_files).returns('plugin2.js')
    @plugins = [plugin1, plugin2]
    expects(:environment).returns(Environment.default).at_least_once
    expects(:profile).returns(nil).at_least_once
    js_tag = noosfero_javascript
    assert_match /plugin1\.js/, js_tag
    assert_match /plugin2\.js/, js_tag
  end

end
