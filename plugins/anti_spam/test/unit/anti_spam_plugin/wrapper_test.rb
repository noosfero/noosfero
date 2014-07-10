require 'test_helper'
require 'anti_spam_plugin/wrapper'

class AntiSpamPluginWrapperTest < ActiveSupport::TestCase

  def teardown
    AntiSpamPlugin::Wrapper.wrappers = []
  end

  should 'use Rakismet::Model' do
    wrapped = AntiSpamPlugin::Wrapper.new(mock)
    assert_includes wrapped.class.included_modules, Rakismet::Model
  end

  should 'wrap object according to wraps? method' do
    class EvenWrapper < AntiSpamPlugin::Wrapper
      def self.wraps?(object)
        object % 2 == 0
      end
    end
    class OddWrapper < AntiSpamPlugin::Wrapper
      def self.wraps?(object)
        object % 2 != 0
      end
    end

    assert AntiSpamPlugin::Wrapper.wrap(5).kind_of?(OddWrapper)
    assert AntiSpamPlugin::Wrapper.wrap(6).kind_of?(EvenWrapper)
  end

  should 'define rakismet_attrs' do
    class AnyWrapper < AntiSpamPlugin::Wrapper
      def self.wraps?(object)
        true
      end
    end

    assert_not_nil AnyWrapper.new(Object.new).send :akismet_data
  end

end
