require 'test_helper'
require 'fileutils'
require_relative '../html5_video_plugin_test_helper'

class PoolManagerTest < ActiveSupport::TestCase

  prepend Html5VideoPluginTestHelper

  def setup
    @pool = VideoProcessor::PoolManager.new(Rails.root.to_s)
  end

  should 'create new file in the waiting pool' do
    file = "#{@pool.path}/waiting/1/10"
    refute File.exist?(file)

    @pool.push(1, 10, '/a/file')
    assert File.exist?(file)
  end

  should 'move file to ongoing pool when assigned from waiting pool' do
    waiting_file = "#{@pool.path}/waiting/1/10"
    ongoing_file = "#{@pool.path}/ongoing/1/10"

    @pool.push(1, 10, '/a/file')
    assert File.exist?(waiting_file)
    refute File.exist?(ongoing_file)

    path = @pool.assign(1, 10)
    refute File.exist?(waiting_file)
    assert File.exist?(ongoing_file)
    assert_equal '/a/file', path
  end

  should 'not move file when assigning from the waiting pool' do
    ongoing_file = "#{@pool.path}/ongoing/1/10"
    @pool.push(1, 10, '/a/file')
    @pool.assign(1, 10)
    assert File.exist?(ongoing_file)

    path = @pool.assign(1, 10, :ongoing)
    assert File.exist?(ongoing_file)
    assert_equal '/a/file', path
  end

  should 'remove file from ongoing pool when it is poped' do
    waiting_file = "#{@pool.path}/waiting/1/10"
    ongoing_file = "#{@pool.path}/ongoing/1/10"

    @pool.push(1, 10, '/a/file')
    @pool.assign(1, 10)
    assert File.exist?(ongoing_file)

    @pool.pop(1, 10)
    refute File.exist?(ongoing_file)
    refute File.exist?(waiting_file)
  end

  should 'return all files for a specific environment' do
    @pool.push(1, 10, '/some/path')
    @pool.push(1, 20, '/some/path')
    @pool.push(1, 30, '/some/path')
    @pool.push(5, 50, '/some/path')
    @pool.assign(1, 30)

    waiting_files = @pool.all_files(1)
    ongoing_files = @pool.all_files(1, :ongoing)

    assert_equivalent ['10', '20'], waiting_files.map{|f| f.split('/').last }
    assert_equivalent ['30'], ongoing_files.map{|name| name.split('/').last }
  end

end
