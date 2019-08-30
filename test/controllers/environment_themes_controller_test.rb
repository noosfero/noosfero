require_relative "../test_helper"

class EnvironmentThemesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @controller = EnvironmentThemesController.new

    Theme.stubs(:user_themes_dir).returns(TMP_THEMES_DIR)

    @env = Environment.default
    login = create_admin_user(@env)
    login_as_rails5(login)
    @profile = User.find_by(login: login).person
  end

  def teardown
    FileUtils.rm_rf(TMP_THEMES_DIR)
  end

  TMP_THEMES_DIR = Rails.root.join("test", "tmp", "environment_themes_controller")

  should "display themes that can be applied" do
    env = Environment.default
    Theme.stubs(:approved_themes).with(@env).returns([])
    t1 = "t1"
    t2 = "t2"
    t3 = "t3"
    env.themes = [t1, t2]
    env.save

    Theme.stubs(:system_themes).returns([Theme.new(t1), Theme.new(t2), Theme.new(t3)])
    get environment_themes_path

    %w[t1 t2].each do |item|
      assert_tag tag: "a", attributes: { href: "/admin/environment_themes/set/#{item}" }
    end

    !assert_tag tag: "a", attributes: { href: "/admin/environment_themes/set/t3" }
  end

  should "highlight current theme" do
    env = Environment.default
    t1 = "butter"
    t2 = "chocolate"
    env.themes = [t1, t2]
    env.save

    Theme.stubs(:system_themes).returns([Theme.new(t1), Theme.new(t2)])
    env.update_theme(t1)
    get environment_themes_path

    assert_tag attributes: { class: "theme-opt list-opt selected" }
    !assert_tag tag: "a", attributes: { href: "/admin/environment_themes/set/butter" }
  end

  should "save selection of theme" do
    get set_environment_theme_path(id: "onetheme")
    env = Environment.default
    assert_equal "onetheme", env.theme
  end

  should "unset selection of theme" do
    get unset_environment_themes_path
    env = Environment.default
    assert_equal "default", env.theme
  end

  should "display link to use the default theme" do
    env = Environment.default
    env.themes = ["new-theme"]
    env.save

    Theme.stubs(:system_themes).returns([Theme.new("new-theme")])

    get environment_themes_path
    assert_tag tag: "a", attributes: { href: "/admin/environment_themes/unset" }
  end

  should "point back to admin panel" do
    get environment_themes_path
    assert_tag tag: "a", attributes: { href: "/admin" }, content: "Back"
  end

  should "list templates" do
    all = LayoutTemplate.all

    LayoutTemplate.expects(:all).returns(all)
    get environment_themes_path
    assert_equivalent all, assigns(:layout_templates)
  end

  should "display links to set template" do
    env = Environment.default
    env.layout_template = "rightbar"
    env.save!
    t1 = LayoutTemplate.find("default")
    t2 = LayoutTemplate.find("leftbar")
    LayoutTemplate.expects(:all).returns([t1, t2])

    get environment_themes_path
    assert_tag tag: "a", attributes: { href: "/admin/environment_themes/set_layout_template/default" }
    assert_tag tag: "a", attributes: { href: "/admin/environment_themes/set_layout_template/leftbar" }
  end

  should "highlight current template" do
    env = Environment.default
    env.update_attribute(:layout_template, "default")
    env.layout_template = "default"

    t1 = LayoutTemplate.find("default")
    t2 = LayoutTemplate.find("leftbar")
    LayoutTemplate.expects(:all).returns([t1, t2])

    get environment_themes_path
    assert_tag attributes: { class: "template-opt list-opt selected" }
    !assert_tag tag: "a", attributes: { href: "/admin/environment_themes/set_layout_template/default" }
  end

  should "set template" do
    env = Environment.default
    post set_layout_template_environment_theme_path(id: "leftbar")
    env.reload
    assert_equal "leftbar", env.layout_template
    assert_redirected_to action: "index"
  end

  should 'not display the "Select themes" section if there are no themes to choose from' do
    env = Environment.default
    env.themes = []; env.save!
    Theme.stubs(:system_themes_dir).returns(TMP_THEMES_DIR) # an empty dir
    get environment_themes_path
    !assert_tag content: "Select theme"
  end
end
