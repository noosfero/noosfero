require File.dirname(__FILE__) + '/abstract_unit'

class TagListTest < Test::Unit::TestCase
  def test_blank?
    assert TagList.new.blank?
  end
  
  def test_equality
    assert_equal TagList.new, TagList.new
    assert_equal TagList.new("tag"), TagList.new("tag")
    
    assert_not_equal TagList.new, ""
    assert_not_equal TagList.new, TagList.new("tag")
  end
  
  def test_parse_leaves_string_unchanged
    tags = '"one  ", two'
    original = tags.dup
    TagList.parse(tags)
    assert_equal tags, original
  end
  
  def test_from_single_name
    assert_equal %w(fun), TagList.from("fun").names
    assert_equal %w(fun), TagList.from('"fun"').names
  end
  
  def test_from_blank
    assert_equal [], TagList.from(nil).names
    assert_equal [], TagList.from("").names
  end
  
  def test_from_single_quoted_tag
    assert_equal ['with, comma'], TagList.from('"with, comma"').names
  end
  
  def test_spaces_do_not_delineate
    assert_equal ['a b', 'c'], TagList.from('a b, c').names
  end
  
  def test_from_multiple_tags
    assert_equivalent %w(alpha beta delta gamma), TagList.from("alpha, beta, delta, gamma").names.sort
  end
  
  def test_from_multiple_tags_with_quotes
    assert_equivalent %w(alpha beta delta gamma), TagList.from('alpha,  "beta",  gamma , "delta"').names.sort
  end
  
  def test_from_multiple_tags_with_quote_and_commas
    assert_equivalent ['alpha, beta', 'delta', 'gamma, something'], TagList.from('"alpha, beta", delta, "gamma, something"').names
  end
  
  def test_from_removes_white_space
    assert_equivalent %w(alpha beta), TagList.from('" alpha   ", "beta  "').names
    assert_equivalent %w(alpha beta), TagList.from('  alpha,  beta ').names
  end
  
  def test_alternative_delimiter
    TagList.delimiter = " "
    
    assert_equal %w(one two), TagList.from("one two").names
    assert_equal ['one two', 'three', 'four'], TagList.from('"one two" three four').names
  ensure
    TagList.delimiter = ","
  end
  
  def test_duplicate_tags_removed
    assert_equal %w(one), TagList.from("one, one").names
  end
  
    def test_to_s_with_commas
    assert_equal "question, crazy animal", TagList.new(["question", "crazy animal"]).to_s
  end
  
  def test_to_s_with_alternative_delimiter
    TagList.delimiter = " "
    
    assert_equal '"crazy animal" question', TagList.new(["crazy animal", "question"]).to_s
  ensure
    TagList.delimiter = ","
  end
  
  def test_add
    tag_list = TagList.new("one")
    assert_equal %w(one), tag_list.names
    
    tag_list.add("two")
    assert_equal %w(one two), tag_list.names
  end
  
  def test_remove
    tag_list = TagList.new("one", "two")
    assert_equal %w(one two), tag_list.names
    
    tag_list.remove("one")
    assert_equal %w(two), tag_list.names
  end
end
