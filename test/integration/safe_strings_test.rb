require_relative "../test_helper"

class SafeStringsTest < ActionDispatch::IntegrationTest
  def setup
    @user = create_user("safestring", password: "123456", password_confirmation: "123456")
    @user.activate!
    @person = user.person
  end

  attr_accessor :user, :person

  should "not escape link to admins on profile page" do
    person = fast_create Person
    community = fast_create Community
    community.add_admin(person)
    get "/profile/#{community.identifier}"
    assert_tag tag: "td", content: "Admins", sibling: {
      tag: "td", child: { tag: "a", content: person.name }
    }
  end

  should "not escape people names on members block" do
    user = create User
    person = user.person
    user.activate!
    community = fast_create Community
    community.add_member(person)
    community.boxes << Box.new
    community.boxes.first.blocks << MembersBlock.new
    get "/profile/#{community.identifier}"
    assert_tag tag: "div", attributes: { id: "block-#{community.blocks.first.id}" }, descendant: {
      tag: "li", attributes: { class: "vcard common-profile-list-block no-pic" }, descendant: {
        tag: "a", attributes: { class: "profile_link", title: person.name }
      }
    }
  end

  should "not escape RawHTMLBlock content" do
    community = fast_create Community
    community.boxes << Box.new
    community.boxes.first.blocks << RawHTMLBlock.new(html: "<b>bold</b>")
    get "/profile/#{community.identifier}"
    assert_tag tag: "div", attributes: { id: "block-#{community.blocks.first.id}" }, descendant: {
      tag: "b", content: "bold"
    }
  end

  should "not escape profile header or footer" do
    community = fast_create Community
    community.update_header_and_footer("<b>header</b>", "<b>footer</b>")
    get "/profile/#{community.identifier}"
    assert_tag tag: "div", attributes: { id: "profile-header" }, child: { tag: "b", content: "header" }
    assert_tag tag: "div", attributes: { id: "profile-footer" }, child: { tag: "b", content: "footer" }
  end

  should "not escape &rarr; symbol from categories" do
    create_user("marley", password: "123456", password_confirmation: "123456").activate!
    category = fast_create Category
    subcategory = fast_create(Category, parent_id: category.id)
    Person["marley"].categories << subcategory
    login_as_rails5 "marley"
    get "/myprofile/marley/profile_editor/categories"
    assert_tag tag: "div", content: /#{category.name} &rarr; #{subcategory.name}/,
               ancestor: { tag: "div", attributes: { class: "selected-category" } }
  end

  should "not escape MainBlock on profile design" do
    create_user("jimi", password: "123456", password_confirmation: "123456").activate!
    jimi = Person["jimi"]
    jimi.boxes << Box.new
    jimi.boxes.first.blocks << MainBlock.new
    login_as_rails5 "jimi"
    get "/myprofile/jimi/profile_design"
    assert_tag tag: "div", attributes: { class: "main-content" }, content: "&lt;Main content&gt;"
  end

  should "not escape confirmation message on deleting folders" do
    create_user("jimi", password: "123456", password_confirmation: "123456").activate!
    fast_create(Folder, name: "Hey Joe", profile_id: Person["jimi"].id, updated_at: DateTime.now)
    login_as_rails5 "jimi"
    get "/myprofile/jimi/cms"
    assert_tag tag: "a", attributes: {
      "data-confirm" => /Are you sure that you want to remove the folder &quot;Hey Joe&quot;\?/
    }
  end

  should "not escape people names on manage friends" do
    create_user("jimi", password: "123456", password_confirmation: "123456").activate!
    friend = fast_create Person
    Person["jimi"].add_friend(friend)
    login_as_rails5 "jimi"
    get "/myprofile/jimi/friends"
    assert_tag tag: "div", attributes: { id: "manage_friends" }, descendant: {
      tag: "a", attributes: { class: "profile-link" }, content: friend.name
    }
  end

  should "not escape task information on manage profile" do
    create_user("marley", password: "123456", password_confirmation: "123456").activate!
    person = Person["marley"]
    task = create(Task, requestor: person, target: person)

    login_as_rails5 "marley"

    get "/myprofile/marley"
    assert_tag tag: "div", attributes: { id: "pending-tasks-menu", class: "noosfero-dropdown-menu" },
               descendant: { tag: "ul", attributes: { class: "dropdown-list" },
                             descendant: { tag: "li",
                                           descendant: { tag: "div", attributes: { class: "task-link" } } } }
  end

  should "not escape author link in publishing info of article" do
    create_user("jimi", password: "test", password_confirmation: "test").activate!
    person = Person["jimi"]
    article = fast_create(Article, author_id: person.id, profile_id: person.id)
    get url_for(article.view_url)
    assert_select ".publishing-info .author a"
  end

  should "not escape tinymce macros when create article" do
    class Plugin1 < Noosfero::Plugin
    end
    class Plugin1::Macro < Noosfero::Plugin::Macro
      def self.configuration
        { params: {} }
      end
    end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([SafeStringsTest::Plugin1.new])

    create_user("jimi", password: "123456", password_confirmation: "123456").activate!
    person = Person["jimi"]
    login_as_rails5 "jimi"
    get "/myprofile/jimi/cms/new?type=TextArticle"
    assert_no_match /title: &quot;Safestringstest::plugin1::macro&quot/, response.body
  end

  should "not escape short_description of articles in activities" do
    user = create_user("marley", password: "123456", password_confirmation: "123456")
    user.activate!
    profile = user.person
    login_as_rails5 "marley"

    expected_content = "something"
    html_content = "<p>#{expected_content}</p>"
    article = TextArticle.create!(profile: profile, name: "An Article about Free Software", body: html_content)
    ActionTracker::Record.destroy_all
    activity = create(ActionTracker::Record, user_id: profile.id, user_type: "Profile", verb: "create_article", target_id: article.id, target_type: "Article", params: { "name" => article.name, "url" => article.url, "lead" => article.lead, "first_image" => article.first_image })
    get "/profile/marley"
    assert_tag "li", attributes: { id: "profile-activity-item-#{activity.id}" }, descendant: {
      tag: "div", attributes: { class: "profile-activity-description profile-activity-article-text-html" }, descendant: {
        tag: "div", attributes: { class: "profile-activity-lead" }
      }
    }
  end

  should "not escape block title when edit a block" do
    class OtherBlock < Block
      def self.description
        _("<p class='other-block'>Other Block</p>")
      end
    end
    login_as_rails5 user.login
    block = OtherBlock.new
    person.boxes.first.blocks << block
    get url_for(action: :edit, controller: :profile_design, profile: person.identifier, id: block.id)
    assert_select ".block-config-options .other-block"
  end

  should "not escape edit settings in highlight block" do
    login_as_rails5 user.login
    block = HighlightsBlock.new
    person.boxes.first.blocks << block
    get url_for(action: :edit, controller: :profile_design, profile: person.identifier, id: block.id)
    assert_select ".block-config-options .image-data-line"
  end

  should "not escape icons options editing link_list block" do
    create_user("jimi", password: "123456", password_confirmation: "123456").activate!
    profile = Person["jimi"]
    login_as_rails5 "jimi"
    profile.blocks.each(&:destroy)
    profile.boxes.first.blocks << LinkListBlock.new
    block = profile.boxes.first.blocks.first
    get "/myprofile/#{profile.identifier}/profile_design/#{block.id}/edit"
    assert_select ".icon-selector"
    assert_tag tag: "span", attributes: { class: "edit" }
  end

  should "not escape read more link to article on display short format" do
    profile = fast_create Profile
    blog = fast_create Blog, name: "Blog", profile_id: profile.id
    fast_create(TextArticle, name: "Post Test", profile_id: profile.id, parent_id: blog.id, accept_comments: false, body: "<p>Lorem ipsum dolor sit amet</p>")
    blog.update_attribute(:visualization_format, "short")

    get "/#{profile.identifier}/blog"
    assert_tag tag: "div", attributes: { class: "read-more" }, child: { tag: "a", content: "Read more" }
  end

  should "not scape sex radio button" do
    env = Environment.default
    env.custom_person_fields = { "sex" => { "active" => "true" } }
    env.save!
    create_user("marley", password: "123456", password_confirmation: "123456").activate!
    login_as_rails5 "marley"
    get "/myprofile/marley/profile_editor/informations"
    assert_tag tag: "input", attributes: { id: "profile_data_sex_male" }
  end
end
