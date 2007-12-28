require File.dirname(__FILE__) + '/../test_helper'

class ActsAsFilesystemTest < Test::Unit::TestCase

  # FIXME shouldn't we test with a non-real model, instead of Article?

  should 'provide a hierarchy list' do
    profile = create_user('testinguser').person

    a1 = profile.articles.build(:name => 'a1'); a1.save!
    a2 = profile.articles.build(:name => 'a2'); a2.parent = a1; a2.save!
    a3 = profile.articles.build(:name => 'a3'); a3.parent = a2; a3.save!

    assert_equal [a1, a2, a3], a3.hierarchy
  end

  should 'be able to optionally reload the hierarchy' do
    a = Article.new
    list = a.hierarchy
    assert_same list, a.hierarchy
    assert_not_same list, a.hierarchy(true)
  end

  should 'list the full tree' do
    profile = create_user('testinguser').person

    a1 = profile.articles.build(:name => 'a1'); a1.save!

    a1_1 = profile.articles.build(:name => 'a1.1'); a1_1.parent = a1; a1_1.save!
    a1_2 = profile.articles.build(:name => 'a1.2'); a1_2.parent = a1; a1_2.save!

    a1_1_1 = profile.articles.build(:name => 'a1.1.1'); a1_1_1.parent = a1_1; a1_1_1.save!
    a1_1_2 = profile.articles.build(:name => 'a1.1.2'); a1_1_2.parent = a1_1; a1_1_2.save!

    assert_equivalent [a1, a1_1, a1_2, a1_1_1, a1_1_2], a1.map_traversal
  end

  should 'be able to traverse with a block' do
    profile = create_user('testinguser').person

    a1 = profile.articles.build(:name => 'a1'); a1.save!

    a1_1 = profile.articles.build(:name => 'a1.1'); a1_1.parent = a1; a1_1.save!
    a1_2 = profile.articles.build(:name => 'a1.2'); a1_2.parent = a1; a1_2.save!

    a1_1_1 = profile.articles.build(:name => 'a1.1.1'); a1_1_1.parent = a1_1; a1_1_1.save!
    a1_1_2 = profile.articles.build(:name => 'a1.1.2'); a1_1_2.parent = a1_1; a1_1_2.save!

    assert_equivalent ['a1', 'a1.1', 'a1.2', 'a1.1.1', 'a1.1.2'], a1.map_traversal { |item| item.name }

  end

  should 'allow dots in slug' do
    assert_equal 'test.txt', Article.new(:name => 'test.txt').slug
  end

end
