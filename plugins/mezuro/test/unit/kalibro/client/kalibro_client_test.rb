require "test_helper"

class KalibroClientTest < ActiveSupport::TestCase

  def setup
    @port = mock
    Kalibro::Client::Port.expects(:new).with('Kalibro').returns(@port)
    @client = Kalibro::Client::KalibroClient.new
  end

  should 'get supported repository types' do
    types = ['BAZAAR', 'GIT', 'SUBVERSION']
    @port.expects(:request).with(:get_supported_repository_types).returns({:repository_type => types})
    assert_equal types, @client.supported_repository_types
  end

  should 'process project' do
    name = 'KalibroClientTest'
    @port.expects(:request).with(:process_project, {:project_name => name})
    @client.process_project(name)
  end

  should 'instantiate for processing project' do
    instance = mock
    Kalibro::Client::KalibroClient.expects(:new).returns(instance)
    instance.expects(:process_project).with('myproject')
    Kalibro::Client::KalibroClient.process_project('myproject', 0)
  end
  
  should 'process project with periodicity' do
  	name = 'KalibroClientTest'
    @port.expects(:request).with(:process_periodically, {:project_name => name, :period_in_days => 30})
    @client.process_periodically(name, 30)
  end
  
  should 'instantiate for processing project periodically' do
    instance = mock
    Kalibro::Client::KalibroClient.expects(:new).returns(instance)
    instance.expects(:process_periodically).with('myproject', 30)
    Kalibro::Client::KalibroClient.process_project('myproject', 30)
  end
  
end
