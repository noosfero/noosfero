require File.dirname(__FILE__) + '/../test_helper'

class MacrosHelperTest < ActionView::TestCase
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

  class Plugin1 < Noosfero::Plugin
  end

  def setup
    Noosfero::Plugin.stubs(:all).returns(['MacrosHelperTest::Plugin1'])
    @environment = Environment.default
    @environment.enable_plugin(Plugin1)
    @plugins = Noosfero::Plugin::Manager.new(@environment, self)
  end

  attr_accessor :environment

  should 'generate html for macro configuration' do
    class Plugin1::Macro < Noosfero::Plugin::Macro
      def self.configuration
        CONFIG
      end
    end

    html = macro_configuration_dialog(Plugin1::Macro)
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
    class Plugin1::Macro < Noosfero::Plugin::Macro
      def self.configuration
        CONFIG
      end
    end
    title = macro_title(Plugin1::Macro)
    assert _('Profile Image Link'), title
  end

  class Plugin1::Macro1 < Noosfero::Plugin::Macro
    def self.configuration
      {}
    end
  end

  class Plugin1::Macro2 < Noosfero::Plugin::Macro
    def self.configuration
      {:icon_path => 'icon.png'}
    end
  end

  should 'get only macros in menu' do
    assert_includes macros_in_menu, Plugin1::Macro1
    assert_not_includes macros_in_menu, Plugin1::Macro2
  end

  should 'get only macros with buttons' do
    assert_includes macros_with_buttons, Plugin1::Macro2
    assert_not_includes macros_with_buttons, Plugin1::Macro1
  end

  should 'skip macro config dialog and call generator directly' do
    class Plugin1::Macro < Noosfero::Plugin::Macro
      def self.configuration
        {:skip_dialog => true, :generator => '', :params => []}
      end
    end

    assert_equal 'function(){}', generate_macro_config_dialog(Plugin1::Macro)
  end

  should 'include js files' do
    class Plugin1::Macro < Noosfero::Plugin::Macro
      def self.configuration
        {:js_files => 'macro.js' }
      end
    end
    ActionView::Helpers::AssetTagHelper::JavascriptIncludeTag.any_instance.stubs('asset_file_path!')
    assert_equal "<script src=\"#{Plugin1.public_path('macro.js')}\" type=\"text/javascript\"></script>", include_macro_js_files
  end

  should 'get macro css files' do
    class Plugin1::Macro < Noosfero::Plugin::Macro
      def self.configuration
        {:css_files => 'macro.css' }
      end

      def self.public_path(file)
        'macro.css'
      end
    end

    assert_equal Plugin1.public_path('macro.css'), macro_css_files
  end

  should 'get macro specific generator' do
    class Plugin1::Macro < Noosfero::Plugin::Macro
      def self.configuration
        {:generator => 'macro_generator' }
      end
    end

    assert_equal 'macro_generator', macro_generator(Plugin1::Macro)
  end

  should 'get macro default generator' do
    class Plugin1::Macro < Noosfero::Plugin::Macro
      def self.configuration
        { :params => [] }
      end
    end
    assert_nothing_raised NoMethodError do
      assert macro_generator(Plugin1::Macro)
    end
  end

  should 'can use a code reference as macro generator' do
    class Plugin1::Macro < Noosfero::Plugin::Macro
      def self.configuration
        { :params => [], :generator => method(:macro_generator_method) }
      end
      def self.macro_generator_method(macro)
        "macro generator method return"
      end
    end
    assert_equal "macro generator method return", macro_generator(Plugin1::Macro)
  end

end
