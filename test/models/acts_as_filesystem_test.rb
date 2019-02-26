require_relative "../test_helper"

class ActsAsFilesystemTest < ActiveSupport::TestCase

  # FIXME shouldn't we test with a non-real model, instead of Article?

  should 'provide a hierarchy list' do
    profile = create_user('testinguser').person

    a1 = profile.articles.create(:name => 'a1')
    a2 = profile.articles.create(:name => 'a2', :parent => a1)
    a3 = profile.articles.create(:name => 'a3', :parent => a2)

    assert_equal [a1, a2, a3], a3.hierarchy
  end

  should 'set ancestry' do
    c1 = create(Category, :name => 'c1')
    c2 = create(Category, :name => 'c2', :parent => c1)
    c3 = create(Category, :name => 'c3', :parent => c2)

    assert_not_nil c1.ancestry
    assert_not_nil c2.ancestry
    assert_equal "%010d.%010d" % [c1.id, c2.id], c3.ancestry
    assert_equal [c1, c2, c3], c3.hierarchy
  end

  should 'provide the level' do
    c1 = create(Category, :name => 'c1')
    c2 = create(Category, :name => 'c2', :parent => c1)
    c3 = create(Category, :name => 'c3', :parent => c2)

    assert_equal 0, c1.level
    assert_equal 1, c2.level
    assert_equal 2, c3.level
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

    items = folder.map_traversal

    assert_includes items, folder
    assert_includes items, article1
    assert_includes items, article2
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
