require_relative '../test_helper'

class ExternalEnvironmentTest < ActiveSupport::TestCase
  def setup
    ExternalEnvironment.destroy_all
  end

  should 'try to process a wrong json without sites key' do
    json = {
      'name' => 'Blogoosfero',
      'url' => 'http://blogoosfero.cc/',
      'id' => 'blogoosfero',
      'screnshot' => 'http://directorncly.noosfero.org/sites/blogoosfero/screenshot.png',
      'thumbnail' => 'http://directory.noosfero.org/sites/blogoosfero/screenshot.thumb.png'
    }
    ExternalEnvironmentUpdater.stubs(:import_json).returns(json)
    ExternalEnvironmentUpdater::process_data

    assert_equal ExternalEnvironment.find_by_url('http://blogoosfero.cc'), nil
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
    ExternalEnvironmentUpdater.stubs(:import_json).returns(json)
    ExternalEnvironmentUpdater::process_data

    assert_equal ExternalEnvironment.find_by_name('Blogoosfero'), nil
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
    ExternalEnvironmentUpdater.stubs(:import_json).returns(json)
    ExternalEnvironmentUpdater::process_data

    assert_equal ExternalEnvironment.find_by_url('test.org'), nil
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
    ExternalEnvironmentUpdater.stubs(:import_json).returns(json)
    ExternalEnvironmentUpdater::process_data

    assert_equal ExternalEnvironment.find_by_url('test.org'), nil
  end

  should 'try to update site info' do
    ExternalEnvironment.create(name: 'Test', url: 'test.org')
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

    ExternalEnvironmentUpdater.stubs(:import_json).returns(json)

    ExternalEnvironmentUpdater::process_data

    external_environment = ExternalEnvironment.find_by_url('test.org')

    assert_equal external_environment.name, 'Test'
    assert_equal external_environment.identifier, 'blogoosfero'
    assert_equal external_environment.screenshot, 'http://directorncly.noosfero.org/sites/blogoosfero/screenshot.png'
    assert_equal external_environment.thumbnail, 'http://directory.noosfero.org/sites/blogoosfero/screenshot.thumb.png'
  end

  should 'external environment should have unique url' do
    f1 = ExternalEnvironment.create(name: 'Test2', url: 'http://www.test.com',
                                 identifier: 'Federation')
    assert(f1.valid?, 'not a valid external environment on f1')

    f2 = ExternalEnvironment.create(name: 'Test3', url: f1.url,
                                 identifier: 'Federation')
    assert_not(f2.valid?, 'f2 should not be a valid external environment')
  end

  should 'validades presence of url on external environment' do
    f = ExternalEnvironment.create(name: 'testname', identifier: 'Federation')
    assert_not(f.valid?, 'should not be a valid external environment')
  end

  should 'external environment should have unique name' do
    f1 = ExternalEnvironment.create(name: 'Test', url: 'http://www.test.com',
                                 identifier: 'Federation')
    assert(f1.valid?, 'not a valid external environment on f1')

    f2 = ExternalEnvironment.create(name: f1.name, url: 'test.org',
                                 identifier: 'Federation2')
    assert_not(f2.valid?, 'f2 should not be a valid external environment')
  end

  should 'validades presence of name on external environment' do
    f = ExternalEnvironment.create(url: 'test.org', identifier: 'Federation')
    assert_not(f.valid?, 'should not be a valid external environment')
  end

  should 'external environment should have unique identifier' do
    f1 = ExternalEnvironment.create(name: 'Test', url: 'http://www.test.com',
                                 identifier: 'Federation')
    assert(f1.valid?, 'not a valid external environment on f1')

    f2 = ExternalEnvironment.create(name: 'Test2', url: 'test.org',
                                 identifier: f1.identifier)
    assert_not(f2.valid?, 'f2 should not be a valid external environment')
  end

  should 'validades presence of identifier on external environment' do
    f = ExternalEnvironment.create(name: 'Test', url: 'test.org')
    assert_not(f.valid?, 'should not be a valid external environment')
  end
end
