require 'test_helper'
require 'content_viewer_controller'

# Re-raise errors caught by the controller.
class ContentViewerController; def rescue_action(e) raise e end; end

class ContentViewerControllerTest < ActionController::TestCase

  def setup
    @controller = ContentViewerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testinguser').person
    @environment = @profile.environment
    @environment.enabled_plugins += ['MetadataPlugin']
    @environment.save!
  end

  attr_reader :profile, :environment

  should 'produce meta tags for profile if on homepage' do
    get :view_page, profile: profile.identifier, page: []
    assert_tag tag: 'meta', attributes: {property: 'og:title', content: profile.name}
  end

  should 'add meta tags with article info' do
    a = TinyMceArticle.create(name: 'Article to be shared', body: 'This article should be shared with all social networks', profile: profile)

    get :view_page, profile: profile.identifier, page: [ a.name.to_slug ]

    assert_tag tag: 'meta', attributes: { name: 'twitter:title', content: /#{a.name} - #{a.profile.name}/ }
    assert_tag tag: 'meta', attributes: { name: 'twitter:description', content: a.body }
    assert_no_tag tag: 'meta', attributes: { name: 'twitter:image' }
    assert_tag tag: 'meta', attributes: { property: 'og:type', content: 'article' }
    assert_tag tag: 'meta', attributes: { property: 'og:url', content: /\/#{profile.identifier}\/#{a.name.to_slug}/ }
    assert_tag tag: 'meta', attributes: { property: 'og:title', content: /#{a.name} - #{a.profile.name}/ }
    assert_tag tag: 'meta', attributes: { property: 'og:site_name', content: a.profile.name }
    assert_tag tag: 'meta', attributes: { property: 'og:description', content: a.body }
    assert_no_tag tag: 'meta', attributes: { property: 'og:image' }
  end

  should 'add meta tags with article images' do
    a = TinyMceArticle.create(name: 'Article to be shared with images', body: 'This article should be shared with all social networks <img src="/images/x.png" />', profile: profile)

    get :view_page, profile: profile.identifier, page: [ a.name.to_slug ]
    assert_tag tag: 'meta', attributes: { name: 'twitter:image', content: /\/images\/x.png/ }
    assert_tag tag: 'meta', attributes: { property: 'og:image', content: /\/images\/x.png/  }
  end

  should 'escape utf8 characters correctly' do
    a = TinyMceArticle.create(name: 'Article to be shared with images', body: 'This article should be shared with all social networks <img src="/images/ç.png" />', profile: profile)

    get :view_page, profile: profile.identifier, page: [ a.name.to_slug ]
    assert_tag tag: 'meta', attributes: { property: 'og:image', content: /\/images\/%C3%A7.png/  }
  end


  should 'render not_found page properly' do
    assert_equal false, Article.exists?(:slug => 'non-existing-page')
    assert_nothing_raised do
      get :view_page, profile: profile.identifier, page: [ 'non-existing-page' ]
      assert_response 404 # not found
      assert_template 'not_found'
    end
  end

  should 'not expose metadata on private pages' do
    profile.update_column :public_profile, false
    a = TinyMceArticle.create(name: 'Article to be shared with images', body: 'This article should be shared with all social networks <img src="/images/x.png" />', profile: profile)

    get :view_page, profile: profile.identifier, page: [ a.name.to_slug ]
    assert_no_tag tag: 'meta', attributes: { property: 'og:image', content: /\/images\/x.png/  }
  end

end
