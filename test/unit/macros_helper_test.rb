require File.dirname(__FILE__) + '/../test_helper'

class MacrosHelperTest < ActiveSupport::TestCase
  include MacrosHelper
  include ApplicationHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::TagHelper

  CONFIG = {
    :params => [
      { :name => :identifier, :type => 'text'},
      { :name => :size, :type => 'select',
        :values => [
          [_('Big'), :big],
          [_('Icon'), :icon],
          [_('Minor'), :minor],
          [_('Portrait'), :portrait],
          [_('Thumb'), :thumb]
        ],
        :default => :portrait
      }
    ],
    :title => _('Profile Image Link')
  }

  should 'generate html for macro configuration' do
    @environment = Environment.default
    Environment.macros = {}
    macros = Environment.macros[@environment.id] = {}
    plugin_instance = mock
    plugin_instance.stubs('config_macro_example').returns(CONFIG)
    macros['macro_example'] = plugin_instance
    html = macro_configuration_dialog('macro_example')
    assert_tag_in_string html, :tag => 'label', :content => _('Identifier')
    assert_tag_in_string html, :tag => 'input', :attributes => {:name => 'identifier'}
    assert_tag_in_string html, :tag => 'label', :content => 'size'.humanize
    assert_tag_in_string html, :tag => 'select', :attributes => {:name => 'size'}, :descendant => {:tag => 'option', :attributes => {:value => 'big'}, :content => _('Big')}
    assert_tag_in_string html, :tag => 'select', :attributes => {:name => 'size'}, :descendant => {:tag => 'option', :attributes => {:value => 'icon'}, :content => _('Icon')}
    assert_tag_in_string html, :tag => 'select', :attributes => {:name => 'size'}, :descendant => {:tag => 'option', :attributes => {:value => 'minor'}, :content => _('Minor')}
    assert_tag_in_string html, :tag => 'select', :attributes => {:name => 'size'}, :descendant => {:tag => 'option', :attributes => {:value => 'portrait', :selected => true}, :content => _('Portrait')}
    assert_tag_in_string html, :tag => 'select', :attributes => {:name => 'size'}, :descendant => {:tag => 'option', :attributes => {:value => 'thumb'}, :content => _('Thumb')}
  end

  should 'get macro title' do
    @environment = Environment.default
    Environment.macros = {}
    macros = Environment.macros[@environment.id] = {}
    plugin_instance = mock
    plugin_instance.stubs('config_macro_example').returns(CONFIG)
    macros['macro_example'] = plugin_instance
    title = macro_title('macro_example')
    assert _('Profile Image Link'), title
  end

  should 'get only macros in menu' do
    @environment = Environment.default
    Environment.macros = {}
    macros = Environment.macros[@environment.id] = {}
    plugin_instance = mock
    plugin_instance.stubs('config_macro_example').returns({})
    macros['macro_example'] = plugin_instance
    plugin_instance_other = mock
    plugin_instance_other.stubs('config_macro_example_other').returns({:icon_path => 'icon.png'})
    macros['macro_example_other'] = plugin_instance_other
    assert_equal [plugin_instance], macros_in_menu.values
  end

  should 'get only macros with buttons' do
    @environment = Environment.default
    Environment.macros = {}
    macros = Environment.macros[@environment.id] = {}
    plugin_instance = mock
    plugin_instance.stubs('config_macro_example').returns({})
    macros['macro_example'] = plugin_instance
    plugin_instance_other = mock
    plugin_instance_other.stubs('config_macro_example_other').returns({:icon_path => 'icon.png'})
    macros['macro_example_other'] = plugin_instance_other
    assert_equal [plugin_instance_other], macros_with_buttons.values
  end

  should 'skip macro config dialog and call generator directly' do
    @environment = Environment.default
    Environment.macros = {}
    macros = Environment.macros[@environment.id] = {}
    plugin_instance = mock
    plugin_instance.stubs('config_macro_example').returns({:skip_dialog => true, :generator => '', :params => [] })
    macros['macro_example'] = plugin_instance
    assert_equal 'function(){}', generate_macro_config_dialog('macro_example')
  end

  should 'include js files' do
    @environment = Environment.default
    Environment.macros = {}
    macros = Environment.macros[@environment.id] = {}
    plugin_instance = mock
    plugin_instance.stubs('config_macro_example').returns({:js_files => 'macro.js' })
    plugin_instance.class.stubs(:public_path).with('macro.js').returns('macro.js')
    macros['macro_example'] = plugin_instance
    assert_equal '<script src="/javascripts/macro.js" type="text/javascript"></script>', include_macro_js_files
  end
  
  should 'get macro css files' do
    @environment = Environment.default
    Environment.macros = {}
    macros = Environment.macros[@environment.id] = {}
    plugin_instance = mock
    plugin_instance.stubs('config_macro_example').returns({:css_files => 'macro.css' })
    plugin_instance.class.stubs(:public_path).with('macro.css').returns('macro.css')
    macros['macro_example'] = plugin_instance
    assert_equal 'macro.css', macro_css_files
  end
  
  should 'get macro specific generator' do
    @environment = Environment.default
    Environment.macros = {}
    macros = Environment.macros[@environment.id] = {}
    plugin_instance = mock
    plugin_instance.stubs('config_macro_example').returns({:generator => 'macro_generator' })
    macros['macro_example'] = plugin_instance
    assert_equal 'macro_generator', macro_generator('macro_example')
  end

end
