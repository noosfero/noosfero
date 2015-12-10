require 'test_helper'

class PiwikPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = PiwikPlugin.new
    @context = mock()
    @plugin.context = @context
    @environment = Environment.new
    @context.stubs(:environment).returns(@environment)
  end

  should 'add content at the body ending unless domain and site_id are blank' do
    @environment.piwik_domain = 'piwik.domain.example.com'
    @environment.piwik_site_id = 5
    @plugin.stubs(:expanded_template).returns('content')
    assert_equal 'content', @plugin.body_ending
  end

  should 'not add any content at the body ending if domain is blank' do
    @environment.piwik_domain = nil
    @environment.piwik_site_id = 5
    @plugin.stubs(:expanded_template).returns('content')
    assert_equal nil, @plugin.body_ending
  end

  should 'not add any content at the body ending if site_id is blank' do
    @environment.piwik_domain = 'piwik.domain.example.com'
    @environment.piwik_site_id = nil
    @plugin.stubs(:expanded_template).returns('content')
    assert_equal nil, @plugin.body_ending
  end

  should 'extends Environment with attr piwik_domain' do
    assert_respond_to Environment.new, :piwik_domain
  end

  should 'extends Environment with attr piwik_site_id' do
    assert_respond_to Environment.new, :piwik_site_id
  end

  should 'set default path to piwik' do
    @environment.piwik_domain = 'piwik.domain.example.com'
    @environment.piwik_site_id = 5
    @plugin.expects(:expanded_template).with('tracking-code.rhtml', {:site_id => @environment.piwik_site_id, :piwik_url => "piwik.domain.example.com/piwik/"})
    @plugin.body_ending
  end

  should 'allow empty path in piwik url' do
    @environment.piwik_domain = 'piwik.domain.example.com'
    @environment.piwik_path = ''
    @environment.piwik_site_id = 5
    @plugin.expects(:expanded_template).with('tracking-code.rhtml', {:site_id => @environment.piwik_site_id, :piwik_url => "piwik.domain.example.com/"})
    @plugin.body_ending
  end

end
