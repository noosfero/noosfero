require File.dirname(__FILE__) + '/../test_helper'

class EnvironmentFinderTest < ActiveSupport::TestCase

  all_fixtures

  should 'find articles' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!
    finder = EnvironmentFinder.new(Environment.default)
    assert_includes finder.find(:articles, 'found'), art
  end

  should 'find people' do
    p1 = create_user('people_1').person; p1.name = 'a beautiful person'; p1.save!
    finder = EnvironmentFinder.new(Environment.default)
    assert_includes finder.find(:people, 'beautiful'), p1
  end

  should 'find communities' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    finder = EnvironmentFinder.new(Environment.default)
    assert_includes finder.find(:communities, 'beautiful'), c1
  end

  should 'find comments' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!
    comment = art.comments.build(:title => 'comment to be found', :body => 'some sample text', :author => person); comment.save!
    assert_includes EnvironmentFinder.new(Environment.default).find(:comments, 'found'), comment
  end

  should 'find products' do
    finder = EnvironmentFinder.new(Environment.default)
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    prod = ent.products.create!(:name => 'a beautiful product')
    assert_includes finder.find(:products, 'beautiful'), prod
  end

  should 'find enterprises' do
    finder = EnvironmentFinder.new(Environment.default)
    ent = Enterprise.create!(:name => 'a beautiful enterprise', :identifier => 'teste')
    assert_includes finder.find(:enterprises, 'beautiful'), ent
  end

  should 'list recent enterprises' do
    finder = EnvironmentFinder.new(Environment.default)
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    assert_includes finder.recent('enterprises'), ent
  end

  should 'not list more enterprises than limit' do
    finder = EnvironmentFinder.new(Environment.default)
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1')
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2')
    recent = finder.recent('enterprises', 1)
    assert_includes recent, ent2 # newer
    assert_not_includes recent, ent1 # older
  end

  should 'count entrprises' do
    finder = EnvironmentFinder.new(Environment.default)
    count = finder.count('enterprises')
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1')
    assert_equal count+1, finder.count('enterprises')
  end

  should 'find articles by initial' do
    person = create_user('teste').person
    art1 = person.articles.create!(:name => 'an article to be found')
    art2 = person.articles.create!(:name => 'blah: an article that cannot be found')
    found = EnvironmentFinder.new(Environment.default).find_by_initial(:articles, 'a')

    assert_includes found, art1
    assert_not_includes found, art2
  end

  should 'find people by initial' do
    finder = EnvironmentFinder.new(Environment.default)
    p1 = create_user('alalala').person
    p2 = create_user('blablabla').person

    found = finder.find_by_initial(:people, 'a')
    assert_includes found, p1
    assert_not_includes found, p2
  end

  should 'find communities by initial' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    c2 = Community.create!(:name => 'b: another beautiful community', :identifier => 'bbbbb', :environment => Environment.default)

    found = EnvironmentFinder.new(Environment.default).find_by_initial(:communities, 'a')

    assert_includes found, c1
    assert_not_includes found, c2
  end

  should 'find comments by initial' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!

    comment1 = art.comments.build(:title => 'a comment to be found', :body => 'some sample text', :author => person); comment1.save!
    comment2 = art.comments.build(:title => 'b: a comment to be found', :body => 'some sample text', :author => person); comment2.save!

    found = EnvironmentFinder.new(Environment.default).find_by_initial(:comments, 'a')

    assert_includes found, comment1
    assert_not_includes found, comment2
  end

  should 'find products by initial' do
    finder = EnvironmentFinder.new(Environment.default)
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    prod1 = ent.products.create!(:name => 'a beautiful product')
    prod2 = ent.products.create!(:name => 'b: a beautiful product')

    found = finder.find_by_initial(:products, 'a')

    assert_includes found, prod1
    assert_not_includes found, prod2
  end

  should 'find enterprises by initial' do
    finder = EnvironmentFinder.new(Environment.default)
    ent1 = Enterprise.create!(:name => 'aaaa', :identifier => 'aaaa')
    ent2 = Enterprise.create!(:name => 'bbbb', :identifier => 'bbbb')

    found = finder.find_by_initial(:enterprises, 'a')

    assert_includes found, ent1
    assert_not_includes found, ent2
  end

end
