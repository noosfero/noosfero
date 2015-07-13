require 'test_helper'

class StoaPlugin::PersonApiTest < ActiveSupport::TestCase

  def setup
    @person = create_user('sample-user').person
  end

  attr_accessor :person

  should 'provide nusp' do
    person.usp_id = '99999999'
    api = StoaPlugin::PersonApi.new(person)
    assert_equal person.usp_id, api.nusp
  end

  should 'provide username' do
    api = StoaPlugin::PersonApi.new(person)
    assert_equal person.user.login, api.username
  end

  should 'provide first_name' do
    person.name = "Jean-Luc Picard"
    api = StoaPlugin::PersonApi.new(person)
    assert_equal 'Jean-Luc', api.first_name
  end

  should 'provide surname' do
    person.name = "Jean-Luc Picard"
    api = StoaPlugin::PersonApi.new(person)
    assert_equal 'Picard', api.surname
  end

  should 'provide homepage' do
    api = StoaPlugin::PersonApi.new(person, self)
    homepage = 'picard.me'
    self.stubs(:url_for).with(person.url).returns(homepage)
    assert_equal homepage, api.homepage
  end

  should 'provide image on base64' do
    person.image_builder = {:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')}
    person.save!
    api = StoaPlugin::PersonApi.new(person)
    assert_equal Base64.encode64(person.image.current_data), api.image_base64
  end

  should 'not crash on image_base64 if profile has no image' do
    api = StoaPlugin::PersonApi.new(person)
    assert_equal nil, api.image_base64
  end

  should 'provide tags' do
    create_article_with_tags(person.id,  'free_software, noosfero, linux')
    create_article_with_tags(person.id,  'free_software, linux')
    create_article_with_tags(person.id,  'free_software')

    api = StoaPlugin::PersonApi.new(person)
    assert_equal person.article_tags, api.tags
  end

  should 'provide tags limited by 10 most relevant' do
    13.times {create_article_with_tags(person.id,  'a')}
    12.times {create_article_with_tags(person.id,  'b')}
    11.times {create_article_with_tags(person.id,  'c')}
    10.times {create_article_with_tags(person.id,  'd')}
    9.times {create_article_with_tags(person.id,  'e')}
    8.times {create_article_with_tags(person.id,  'f')}
    7.times {create_article_with_tags(person.id,  'g')}
    6.times {create_article_with_tags(person.id,  'h')}
    5.times {create_article_with_tags(person.id,  'i')}
    4.times {create_article_with_tags(person.id,  'j')}
    3.times {create_article_with_tags(person.id,  'l')}
    2.times {create_article_with_tags(person.id,  'm')}
    1.times {create_article_with_tags(person.id,  'n')}

    api = StoaPlugin::PersonApi.new(person)
    tags = api.tags
    assert_equal 10, tags.size
    assert tags['a']
    assert tags['b']
    assert tags['c']
    assert tags['d']
    assert tags['e']
    assert tags['f']
    assert tags['g']
    assert tags['h']
    assert tags['i']
    assert tags['j']
    assert_nil tags['l']
    assert_nil tags['m']
    assert_nil tags['n']
  end

  should 'not provide information of private articles tags' do
    create_article_with_tags(person.id,  'free_software, noosfero, linux', {:published => false})
    create_article_with_tags(person.id,  'free_software, linux')
    create_article_with_tags(person.id,  'free_software')

    api = StoaPlugin::PersonApi.new(person)
    assert !api.tags.has_key?('noosfero')
  end

  should 'provide communities' do
    c1 = fast_create(Community)
    c2 = fast_create(Community)
    c3 = fast_create(Community)
    c1.add_member(person)
    c2.add_member(person)
    c1_homepage = 'c1.org'
    c2_homepage = 'c2.org'
    self.stubs(:url_for).with(c1.url).returns(c1_homepage)
    self.stubs(:url_for).with(c2.url).returns(c2_homepage)
    communities = [{:url => c1_homepage, :name => c1.name}, {:url => c2_homepage, :name => c2.name}]
    api = StoaPlugin::PersonApi.new(person, self)

    assert_equivalent communities, api.communities
  end

  should 'not provide private communities' do
    c1 = fast_create(Community)
    c2 = fast_create(Community, :public_profile => false)
    c3 = fast_create(Community, :visible => false)
    c1.add_member(person)
    c2.add_member(person)
    c3.add_member(person)
    c1_homepage = 'c1.org'
    c2_homepage = 'c2.org'
    self.stubs(:url_for).with(c1.url).returns(c1_homepage)
    self.stubs(:url_for).with(c2.url).returns(c2_homepage)
    communities = [{:url => c1_homepage, :name => c1.name}]
    api = StoaPlugin::PersonApi.new(person, self)

    assert_equivalent communities, api.communities
  end

  private

  def create_article_with_tags(profile_id, tags = '', options = {})
    article = fast_create(Article, options.merge(:profile_id => profile_id))
    article.tag_list = tags
    article.save!
    article
  end
end
