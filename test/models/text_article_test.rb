require_relative "../test_helper"

class TextArticleTest < ActiveSupport::TestCase

  # mostly dummy test. Can be removed when (if) there are real tests for this
  # this class.
  should 'inherit from Article' do
    assert_kind_of Article, TextArticle.new
  end

  should 'be translatable' do
    assert_kind_of TranslatableContent, TextArticle.new
  end

  should 'return article icon name' do
    assert_equal Article.icon_name, TextArticle.icon_name
  end

  should 'return blog icon name if the article is a blog post' do
    blog = fast_create(Blog)
    article = TextArticle.new
    article.parent = blog
    assert_equal Blog.icon_name, TextArticle.icon_name(article)
  end

  should 'change image path to relative' do
    person = create_user('testuser').person
    article = TextArticle.new(:profile => person, :name => 'test')
    env = Environment.default
    article.body = "<img src=\"http://#{env.default_hostname}/test.png\" />"
    article.save!
    assert_equal "<img src=\"/test.png\">", article.body
  end

  should 'change link to relative path' do
    person = create_user('testuser').person
    article = TextArticle.new(:profile => person, :name => 'test')
    env = Environment.default
    article.body = "<a href=\"http://#{env.default_hostname}/test\">test</a>"
    article.save!
    assert_equal "<a href=\"/test\">test</a>", article.body
  end

  should 'change image path to relative for domain with https' do
    person = create_user('testuser').person
    article = TextArticle.new(:profile => person, :name => 'test')
    env = Environment.default
    article.body = "<img src=\"https://#{env.default_hostname}/test.png\">"
    article.save!
    assert_equal "<img src=\"/test.png\">", article.body
  end

  should 'change image path to relative for domain with port' do
    person = create_user('testuser').person
    article = TextArticle.new(:profile => person, :name => 'test')
    env = Environment.default
    article.body = "<img src=\"http://#{env.default_hostname}:3000/test.png\">"
    article.save!
    assert_equal "<img src=\"/test.png\">", article.body
  end

  should 'change image path to relative for domain with www' do
    person = create_user('testuser').person
    article = TextArticle.new(:profile => person, :name => 'test')
    env = Environment.default
    env.force_www = true
    env.save!
    article.body = "<img src=\"http://#{env.default_hostname}:3000/test.png\">"
    article.save!
    assert_equal "<img src=\"/test.png\">", article.body
  end

  should 'change image path to relative for profile with own domain' do
    person = create_user('testuser').person
    person.domains << build(Domain)

    article = TextArticle.new(:profile => person, :name => 'test')
    env = Environment.default
    article.body = "<img src=\"http://#{person.default_hostname}:3000/link-profile.png\">"
    article.save!
    assert_equal "<img src=\"/link-profile.png\">", article.body
  end

  should 'not be translatable if there is no language available on environment' do
    environment = fast_create(Environment)
    environment.languages = nil
    profile = fast_create(Person, :environment_id => environment.id)

    text = TextArticle.new(:profile => profile)

    refute text.translatable?
  end

  should 'be translatable if there is languages on environment' do
    environment = fast_create(Environment)
    environment.languages = nil
    profile = fast_create(Person, :environment_id => environment.id)
    text = fast_create(TextArticle, :profile_id => profile.id)

    refute text.translatable?

    environment.languages = ['en','pt','fr']
    environment.save
    text.reload
    assert text.translatable?
  end

  should 'display preview when configured on parent that is a blog' do
    person = fast_create(Person)
    post = fast_create(TextArticle, :profile_id => person.id)
    blog = Blog.new(:display_preview => true)
    post.parent = blog
    assert post.display_preview?
  end

  should 'provide HTML version for textile editor' do
    profile = create_user('testinguser').person
    a = fast_create(TextArticle, :body => '*my text*', :profile_id => profile.id, :editor => Article::Editor::TEXTILE)
    assert_equal '<p><strong>my text</strong></p>', a.to_html
  end

  should 'provide HTML version for body lead textile editor' do
    profile = create_user('testinguser').person
    a = fast_create(TextArticle, :body => '*my text*', :profile_id => profile.id, :editor => Article::Editor::TEXTILE)
    assert_equal '<p><strong>my text</strong></p>', a.lead
  end

  should 'provide HTML version for abstract lead textile editor' do
    profile = create_user('testinguser').person
    a = fast_create(TextArticle, :abstract => '*my text*', :profile_id => profile.id, :editor => Article::Editor::TEXTILE)
    assert_equal '<p><strong>my text</strong></p>', a.lead
  end

end
