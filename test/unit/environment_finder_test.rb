require File.dirname(__FILE__) + '/../test_helper'

class EnvironmentFinderTest < ActiveSupport::TestCase
  
  should 'find articles' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!
    finder = EnvironmentFinder.new(Environment.default)
    assert_includes finder.articles, art
  end

  should 'find people' do
    p1 = create_user('people_1').person; p1.name = 'a beautiful person'; p1.save!
    finder = EnvironmentFinder.new(Environment.default)
    assert_includes finder.people, p1
  end

  should 'find communities' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    finder = EnvironmentFinder.new(Environment.default)
    assert_includes finder.communities, c1
  end

  should 'find comments' do
    finder = EnvironmentFinder.new(Environment.default)
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!
    comment = art.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment.save!
    assert_includes finder.comments, comment
  end

  should 'find products' do
    finder = EnvironmentFinder.new(Environment.default)
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    prod = ent.products.create!(:name => 'a beautiful product')
    assert_includes finder.products, prod
  end

  should 'find enterprises' do
    finder = EnvironmentFinder.new(Environment.default)
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    assert_includes finder.enterprises, ent
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
    assert_includes recent, ent1
    assert_not_includes recent, ent2
  end

  should 'count entrprises' do
    finder = EnvironmentFinder.new(Environment.default)
    count = finder.count('enterprises')
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1')
    assert_equal count+1, finder.count('enterprises')
  end

end
