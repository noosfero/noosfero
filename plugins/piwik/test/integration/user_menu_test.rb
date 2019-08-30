require "test_helper"

class AssetsMenuTest < ActionDispatch::IntegrationTest
  def setup
    @person = create_user("testuser").person
    @environment = Environment.default

    @environment.enable_plugin(PiwikPlugin)
    @person.user.activate!
    login_as_rails5("testuser")
  end

  should "not display link if piwik domain was not set" do
    @environment.add_admin @person

    get "/"
    !assert_tag "a", attributes: { href: /piwik.org/ },
                     ancestor: { tag: "ul", attributes: { class: "noosfero-dropdown-menu" } }
  end

  should "not display piwik link if the user is not admin" do
    @environment.piwik_domain = "piwik.org"
    @environment.save

    get "/"
    !assert_tag "a", attributes: { href: /piwik.org/ },
                     ancestor: { tag: "ul", attributes: { class: "noosfero-dropdown-menu" } }
  end

  should "display piwik link with http if request does not use SSL" do
    ActionDispatch::Request.any_instance.stubs(:ssl?).returns(false)
    @environment.add_admin @person
    @environment.piwik_domain = "piwik.org"
    @environment.save

    get "/"
    assert_tag "a", attributes: { href: /^\/\/piwik.org/ },
                    ancestor: { tag: "ul", attributes: { class: "noosfero-dropdown-menu" } }
  end

  should "display piwik link with https if request uses SSL" do
    ActionDispatch::Request.any_instance.stubs(:ssl?).returns(true)
    @environment.add_admin @person
    @environment.piwik_domain = "piwik.org"
    @environment.save

    get "/"
    assert_tag "a", attributes: { href: /^\/\/piwik.org/ },
                    ancestor: { tag: "ul", attributes: { class: "noosfero-dropdown-menu" } }
  end
end
