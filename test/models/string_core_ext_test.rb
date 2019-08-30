# encoding: UTF-8

require_relative "../test_helper"

# tests for String core extension. See lib/noosfero/core_ext/string.rb
class StringCoreExtTest < ActiveSupport::TestCase
  # tests for String#to_slug
  should "keep only alphanum" do
    assert_equal "abc", "abc!)@(*#&@!*#*)".to_slug
  end

  should "turn punctuation into dashes" do
    assert_equal "a-b-c-d-e-f", "a:b;c+d=e_f".to_slug
  end

  should "truncate dashes" do
    assert_equal "a-b-c", "a---b: c ;;;".to_slug
  end

  should "turn spaces into dashes" do
    assert_equal "a-b", "a b".to_slug
  end

  should "not remove dots" do
    assert_equal "a.b", "a.b".to_slug
  end

  should "handle multy-byte UTF-8 characters properly" do
    assert_equal "\u65E5\u672C\u8A9E\u30ED\u30FC\u30AB\u30E9\u30A4\u30BA\u30C1\u30FC\u30E0-home", "\u65E5\u672C\u8A9E\u30ED\u30FC\u30AB\u30E9\u30A4\u30BA\u30C1\u30FC\u30E0_HOME".to_slug
  end

  # tests for String#transliterate
  should "transliterate" do
    assert_equal "aaaaaaAAAAAeeeeEEOOoocaaaiIIiuuyYnNcC", "\u00AA\u00E1\u00E0\u00E4\u00E2\u00E5\u00C1\u00C0\u00C4\u00C2\u00C5\u00E9\u00E8\u00EB\u00EA\u00CA\u00CB\u00D6\u00D4\u00F6\u00F4\u00E7\u00E4\u00E0\u00E2\u00EE\u00CF\u00CE\u00EF\u00FB\u00FC\u00FF\u0178\u00F1\u00D1\u00E7\u00C7".transliterate
  end

  should "convert to css class" do
    assert_equal "spaceship-propulsion_warp-core", "SpaceshipPropulsion::WarpCore".to_css_class
  end
end
