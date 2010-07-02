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

    a1_1 = a1.children.create!(:name => 'a1.1', :profile => profile)

    a1_2 = a1.children.create!(:name => 'a1.2', :profile => profile)

    a1_1_1 = a1_1.children.create!(:name => 'a1.1.1', :profile => profile)
    a1_1_2 = a1_1.children.create!(:name => 'a1.1.2', :profile => profile)

    a1.reload

    assert_equivalent [a1, a1_1, a1_2, a1_1_1, a1_1_2], a1.map_traversal
  end

  should 'list the full tree without the root' do
    profile = create_user('testinguser').person

    a1 = profile.articles.build(:name => 'a1'); a1.save!

    a1_1 = a1.children.create!(:name => 'a1.1', :profile => profile)

    a1_2 = a1.children.create!(:name => 'a1.2', :profile => profile)

    a1_1_1 = a1_1.children.create!(:name => 'a1.1.1', :profile => profile)
    a1_1_2 = a1_1.children.create!(:name => 'a1.1.2', :profile => profile)

    a1.reload

    assert_equivalent [a1_1, a1_2, a1_1_1, a1_1_2].map(&:id), a1.all_children.map(&:id)
  end

  should 'be able to traverse with a block' do
    profile = create_user('testinguser').person

    a1 = profile.articles.build(:name => 'a1'); a1.save!

    a1_1 = a1.children.create!(:name => 'a1.1', :profile => profile)

    a1_2 = a1.children.create!(:name => 'a1.2', :profile => profile)

    a1_1_1 = a1_1.children.create!(:name => 'a1.1.1', :profile => profile)
    a1_1_2 = a1_1.children.create!(:name => 'a1.1.2', :profile => profile)

    a1.reload

    assert_equivalent ['a1', 'a1.1', 'a1.2', 'a1.1.1', 'a1.1.2'], a1.map_traversal { |item| item.name }

  end

  should 'be able to list text articles that are children of a folder' do
    profile = create_user('testinguser').person
    folder = fast_create(Folder, :name => 'folder', :profile_id => profile.id)
    article1 = Article.create!(:name => 'article 1', :profile => profile, :parent => folder)
    article2 = Article.create!(:name => 'article 2', :profile => profile, :parent => folder)
    folder.reload

    assert_equal [folder, article1, article2], folder.map_traversal
  end

  should 'allow dots in slug' do
    assert_equal 'test.txt', Article.new(:name => 'test.txt').slug
  end

  should 'provide name without leading parents' do
    a = Article.new
    a.expects(:full_name).with('/').returns('a/b/c/d').times(3)
    assert_equal 'b/c/d', a.full_name_without_leading(1)
    assert_equal 'c/d', a.full_name_without_leading(2)
    assert_equal 'd', a.full_name_without_leading(3)
  end

  should 'cache children count' do
    profile = create_user('testinguser').person
    a1 = profile.articles.create!(:name => 'a1')
    a11 = profile.articles.create!(:name => 'a11', :parent => a1)
    a12 = profile.articles.create!(:name => 'a12', :parent => a1)
  end

end
