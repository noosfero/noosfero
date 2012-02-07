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
    Kalibro::Client::KalibroClient.process_project('myproject')
  end
  
end
