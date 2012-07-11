require "test_helper"

class KalibroClientTest < ActiveSupport::TestCase

  def setup
    @name = 'KalibroTest'
  end   
  
  should 'get supported repository types' do
    types = ['BAZAAR', 'GIT', 'SUBVERSION']
    Kalibro::Kalibro.expects(:request).with('Kalibro', :get_supported_repository_types).returns({:repository_type => types})
    assert_equal types, Kalibro::Kalibro.repository_types
  end

  should 'process project without days' do
    Kalibro::Kalibro.expects(:request).with('Kalibro', :process_project, {:project_name => @name})
    Kalibro::Kalibro.process_project(@name)
  end

  should 'process project with days' do
    Kalibro::Kalibro.expects(:request).with('Kalibro', :process_periodically, {:project_name => @name, :period_in_days => "1"})
    Kalibro::Kalibro.process_project(@name, "1")
  end

  should 'process period' do
    Kalibro::Kalibro.expects(:request).with('Kalibro', :get_process_period,  {:project_name => @name}).returns({:period => "1"})
    assert_equal "1", Kalibro::Kalibro.process_period(@name)
  end
  
  should 'cancel periodic process' do
    Kalibro::Kalibro.expects(:request).with("Kalibro", :cancel_periodic_process, {:project_name => @name})
    Kalibro::Kalibro.cancel_periodic_process(@name)
  end
end
