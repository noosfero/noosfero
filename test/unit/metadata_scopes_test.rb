require_relative '../test_helper'

class MetadataScopesTest < ActiveSupport::TestCase

  class FooPlugin < Noosfero::Plugin; end
  class Foo; end

  def setup
    @profile1 = create_user.person
    @profile2 = fast_create(Community)
    @profile3 = fast_create(Enterprise)
    Foo.stubs(:attr_accessible)
  end

  should 'return all profiles that defined a metadata' do
    @profile1.metadata[:attr] = true; @profile1.save
    @profile2.metadata[:not_attr] = true; @profile2.save
    @profile3.metadata[:attr] = true; @profile3.save

    assert_equivalent [@profile1, @profile3], Profile.has_metadata(:attr)
  end

  should 'return profiles with metadata that matches a value' do
    @profile1.metadata[:attr] = true; @profile1.save
    @profile2.metadata[:attr] = true
    @profile2.metadata[:not_attr] = false; @profile2.save

    assert_equivalent [@profile1, @profile2],
                      Profile.with_metadata(attr: true)
    assert_equivalent [@profile2],
                      Profile.with_metadata(attr: true, not_attr: false)
  end

  should 'return profiles with namespaced metadata that matches a value' do
    Noosfero::Plugin::Metadata.new(@profile1, FooPlugin, attr: true).save!
    Noosfero::Plugin::Metadata.new(@profile3, FooPlugin, attr: true,
                                   not_attr: false).save!

    assert_equivalent [@profile1, @profile3],
                      Profile.with_plugin_metadata(FooPlugin, attr: true)
    assert_equivalent [@profile3],
                      Profile.with_plugin_metadata(FooPlugin, attr: true,
                                                   not_attr: false)
  end

  should 'define getters and setters for each metadata item' do
    Foo.stubs(:scope) # mocks ActiveRecord methods
    Foo.class_eval do
      include MetadataScopes
      def metadata
        {}
      end
      metadata_items :item1, :item2
    end

    foo = Foo.new
    assert foo.respond_to? :item1
    assert foo.respond_to? :item1=
    assert foo.respond_to? :item2
    assert foo.respond_to? :item2=
  end

end
