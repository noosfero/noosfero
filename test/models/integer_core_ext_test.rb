require_relative "../test_helper"

# tests for Integer core extension. See lib/noosfero/core_ext/integer.rb
class IntegerCoreExtTest < ActiveSupport::TestCase

  should 'display bytes in human readable' do
    assert_equal '2 bytes', 2.bytes.to_humanreadable
  end

  should 'display kilobytes in human readable' do
    assert_equal '1.0 KB', 1.kilobytes.to_humanreadable
  end

  should 'display megabytes in human readable' do
    assert_equal '1.0 MB', 1.megabytes.to_humanreadable
  end

  should 'display gigabytes in human readable' do
    assert_equal '1.0 GB', 1.gigabytes.to_humanreadable
  end

  should 'display terabytes in human readable' do
    assert_equal '1.0 TB', 1.terabytes.to_humanreadable
  end

  should 'display petabytes in human readable' do
    assert_equal '1.0 PB', 1.petabytes.to_humanreadable
  end

  should 'display exabytes in human readable' do
    assert_equal '1.0 EB', 1.exabytes.to_humanreadable
  end

end
