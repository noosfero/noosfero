require "#{File.dirname(__FILE__)}/../test_helper"

class EventTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
    @profile = create_user('testing').person
  end

  attr_accessor :environment, :profile

  should 'be indexed by title' do
    TestSolr.enable
    e = Event.create!(:name => 'my surprisingly nice event', :start_date => Date.new(2008, 06, 06), :profile => profile)
    assert_includes Event.find_by_contents('surprisingly')[:results], e
  end

  should 'be indexed by body' do
    TestSolr.enable
    e = Event.create!(:name => 'bli', :start_date => Date.new(2008, 06, 06), :profile => profile, :body => 'my surprisingly long description about my freaking nice event')
    assert_includes Event.find_by_contents('surprisingly')[:results], e
  end
end
