require_relative "../test_helper"

# tests for String#to_slug core extension. See lib/noosfero/core_ext/string.rb
class SlugTest < ActiveSupport::TestCase

  should 'keep only alphanum' do
    assert_equal 'abc', 'abc!)@(*#&@!*#*)'.to_slug
  end

  should 'turn punctuation into s' do
    assert_equal 'a-b-c-d-e-f', 'a:b;c+d=e_f'.to_slug
  end

  should 'truncate dashes' do
    assert_equal 'a-b-c', 'a---b: c ;;;'.to_slug
  end

  should 'turn spaces into dashes' do
    assert_equal 'a-b', 'a b'.to_slug
  end

  should 'not remove dots' do
    assert_equal 'a.b', 'a.b'.to_slug
  end

  should 'turn quote and apostrophe into dashes' do
    assert_equal 'a-b-c-d', 'a"b\'c`d'.to_slug
  end

  should 'not remove numbers in beginning of slug' do
    assert_equal '3-times', '3 times'.to_slug
    assert_equal '3x640.jpg', '3x640.jpg'.to_slug
  end

end
