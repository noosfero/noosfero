require_relative "../test_helper"

class StringTemplatesTest < ActionDispatch::IntegrationTest

  def setup
    @profile = create_user('testuser', password: 'test').person
    @profile.user.activate
    login(@profile.identifier, 'test')
  end

  should 'replace block content when there is a valid macro' do
    block = LinkListBlock.new(:links => [
      {:name => "Links for !identifier.", :address => 'test.com'}
    ])
    @profile.boxes.first.blocks << block

    get "/#{@profile.identifier}"
    assert_no_match /Links for !identifier\./, @response.body
    assert_match /Links for #{@profile.identifier}\./, @response.body
  end

  should 'replace article body when there is a valid macro' do
    article = fast_create(TextArticle,
      author_id: @profile.id,
      profile_id: @profile.id,
      body: '<p>The title is: !title</p>'
    )

    get "/#{@profile.identifier}/#{article.title.to_slug}"
    assert_no_match /<p>The title is: !title<\/p>/, @response.body
    assert_match /<p>The title is: #{article.title}<\/p>/, @response.body
  end

  should 'not replace the content if the macro is invalid' do
    article = fast_create(TextArticle,
      author_id: @profile.id,
      profile_id: @profile.id,
      body: '<p>!invalid-macro should stay</p>'
    )

    get "/#{@profile.identifier}/#{article.title.to_slug}"
    assert_match /<p>!invalid-macro should stay<\/p>/, @response.body
  end

  should 'replace the title of an article if the macro is valid' do
    article = TextArticle.create name: 'Hello, !name', author: @profile, profile: @profile, published: true
    get "/#{@profile.identifier}/#{article.name.to_slug}"
    assert_no_match /Hello, !name/, @response.body
    assert_match /Hello, #{@profile.name}/, @response.body
  end

  should 'not replace the title of an article if the macro is invalid' do
    article = TextArticle.create name: 'Hello, !invalid-macro', author: @profile, profile: @profile, published: true
    get "/#{@profile.identifier}/#{article.name.to_slug}"
    assert_match /Hello, !invalid-macro/, @response.body
  end
end
