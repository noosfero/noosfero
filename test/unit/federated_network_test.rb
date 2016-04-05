require_relative '../test_helper'

class FederatedNetworkTest < ActiveSupport::TestCase
  def setup
    FederatedNetwork.destroy_all
  end

  should 'try to process a wrong json without sites key' do
    json = {
      'name' => 'Blogoosfero',
      'url' => 'http://blogoosfero.cc/',
      'id' => 'blogoosfero',
      'screnshot' => 'http://directorncly.noosfero.org/sites/blogoosfero/screenshot.png',
      'thumbnail' => 'http://directory.noosfero.org/sites/blogoosfero/screenshot.thumb.png'
    }
    FederatedNetworkUpdater.stubs(:import_json).returns(json)
    FederatedNetworkUpdater::process_data

    assert_equal FederatedNetwork.find_by_url('http://blogoosfero.cc'), nil
  end

  should 'try to process a wrong json with sites but without url' do
    json = {
      'sites' => [
        { 'name' => 'Blogoosfero',
          'id' => 'blogoosfero',
          'screnshot' => 'http://directorncly.noosfero.org/sites/blogoosfero/screenshot.png',
          'thumbnail' => 'http://directory.noosfero.org/sites/blogoosfero/screenshot.thumb.png'
        }
      ]
    }
    FederatedNetworkUpdater.stubs(:import_json).returns(json)
    FederatedNetworkUpdater::process_data

    assert_equal FederatedNetwork.find_by_name('Blogoosfero'), nil
  end

  should 'try to process a wrong json with sites but without name' do
    json = {
      'sites' => [
        { 'url' => 'test.org',
          'id' => 'blogoosfero',
          'screnshot' => 'http://directorncly.noosfero.org/sites/blogoosfero/screenshot.png',
          'thumbnail' => 'http://directory.noosfero.org/sites/blogoosfero/screenshot.thumb.png'
        }
      ]
    }
    FederatedNetworkUpdater.stubs(:import_json).returns(json)
    FederatedNetworkUpdater::process_data

    assert_equal FederatedNetwork.find_by_url('test.org'), nil
  end

  should 'try to process a wrong json with sites but without identifier' do
    json = {
      'sites' => [
        { 'name' => 'Blogoosfero',
          'url' => 'test.org',
          'screnshot' => 'http://directorncly.noosfero.org/sites/blogoosfero/screenshot.png',
          'thumbnail' => 'http://directory.noosfero.org/sites/blogoosfero/screenshot.thumb.png'
        }
      ]
    }
    FederatedNetworkUpdater.stubs(:import_json).returns(json)
    FederatedNetworkUpdater::process_data

    assert_equal FederatedNetwork.find_by_url('test.org'), nil
  end

  should 'try to update site info' do
    FederatedNetwork.create(name: 'Test', url: 'test.org')
    json = {
      'sites' => [
        { 'name' => 'Test',
          'url' => 'test.org',
          'id' => 'blogoosfero',
          'screnshot' => 'http://directorncly.noosfero.org/sites/blogoosfero/screenshot.png',
          'thumbnail' => 'http://directory.noosfero.org/sites/blogoosfero/screenshot.thumb.png'
        }
      ]
    }

    FederatedNetworkUpdater.stubs(:import_json).returns(json)

    FederatedNetworkUpdater::process_data

    federated_network = FederatedNetwork.find_by_url('test.org')

    assert_equal federated_network.name, 'Test'
    assert_equal federated_network.identifier, 'blogoosfero'
    assert_equal federated_network.screenshot, 'http://directorncly.noosfero.org/sites/blogoosfero/screenshot.png'
    assert_equal federated_network.thumbnail, 'http://directory.noosfero.org/sites/blogoosfero/screenshot.thumb.png'
  end

  should 'federated network should have unique url' do
    f1 = FederatedNetwork.create(name: 'Test2', url: 'http://www.test.com',
                                 identifier: 'Federation')
    assert(f1.valid?, 'not a valid federated network on f1')

    f2 = FederatedNetwork.create(name: 'Test3', url: f1.url,
                                 identifier: 'Federation')
    assert_not(f2.valid?, 'f2 should not be a valid federated network')
  end

  should 'validades presence of url on federated network' do
    f = FederatedNetwork.create(name: 'testname', identifier: 'Federation')
    assert_not(f.valid?, 'should not be a valid federated network')
  end

  should 'federated network should have unique name' do
    f1 = FederatedNetwork.create(name: 'Test', url: 'http://www.test.com',
                                 identifier: 'Federation')
    assert(f1.valid?, 'not a valid federated network on f1')

    f2 = FederatedNetwork.create(name: f1.name, url: 'test.org',
                                 identifier: 'Federation2')
    assert_not(f2.valid?, 'f2 should not be a valid federated network')
  end

  should 'validades presence of name on federated network' do
    f = FederatedNetwork.create(url: 'test.org', identifier: 'Federation')
    assert_not(f.valid?, 'should not be a valid federated network')
  end

  should 'federated network should have unique identifier' do
    f1 = FederatedNetwork.create(name: 'Test', url: 'http://www.test.com',
                                 identifier: 'Federation')
    assert(f1.valid?, 'not a valid federated network on f1')

    f2 = FederatedNetwork.create(name: 'Test2', url: 'test.org',
                                 identifier: f1.identifier)
    assert_not(f2.valid?, 'f2 should not be a valid federated network')
  end

  should 'validades presence of identifier on federated network' do
    f = FederatedNetwork.create(name: 'Test', url: 'test.org')
    assert_not(f.valid?, 'should not be a valid federated network')
  end
end
