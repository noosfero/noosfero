require_relative "../test_helper"

class RecentDocumentsBlockTest < ActiveSupport::TestCase
  include ActionView::Helpers::OutputSafetyHelper

  def setup
    @articles = []
    @profile = create_user("testinguser").person
    @profile.articles.destroy_all
    ["first", "second", "third", "fourth", "fifth"].each do |name|
      article = @profile.articles.create!(name: name)
      @articles << article
    end

    box = Box.new
    box.owner = profile
    box.save!

    @block = RecentDocumentsBlock.new
    @block.box_id = box.id
    @block.save!
  end
  attr_reader :block, :profile, :articles

  should "describe itself" do
    assert_not_equal Block.description, RecentDocumentsBlock.description
  end

  should "provide a default title" do
    assert_not_equal Block.new.default_title, RecentDocumentsBlock.new.default_title
  end

  should "list recent documents" do
    assert_equivalent block.docs, articles
  end

  should "respect the maximum number of items as configured" do
    block.limit = 3

    list = block.docs

    assert_includes list, articles[4]
    assert_includes list, articles[3]
    assert_includes list, articles[2]
    assert_not_includes list, articles[1]
    assert_not_includes list, articles[0]
  end

  should "store limit as a number" do
    block.limit = ""
    assert block.limit.is_a?(Integer)
  end

  should "have a non-zero default" do
    block.limit = nil
    assert block.limit > 0
  end

  should "be able to update display setting" do
    assert @block.update!(display: "always")
    @block.reload
    assert_equal "always", @block.display
  end

  should "return the max value in the range between zero and limit" do
    block = RecentDocumentsBlock.new
    assert_equal 5, block.get_limit
  end

  should "return 0 if limit of the block is negative" do
    block = RecentDocumentsBlock.new
    block.limit = -5
    assert_equal 0, block.get_limit
  end
end

require "boxes_helper"

class RecentDocumentsBlockViewTest < ActionView::TestCase
  include BoxesHelper

  def setup
    @articles = []
    @profile = create_user("testinguser").person
    @profile.articles.destroy_all
    ["first", "second", "third", "fourth", "fifth"].each do |name|
      article = @profile.articles.create!(name: name)
      @articles << article
    end

    box = Box.new
    box.owner = profile
    box.save!

    @block = RecentDocumentsBlock.new
    @block.box_id = box.id
    @block.save!
  end
  attr_reader :block, :profile, :articles

  should "link to documents" do
    articles.each do |a|
      ActionView::Base.any_instance.expects(:link_to).with(a.title, a.url)
    end
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:content_tag).returns("")
    ActionView::Base.any_instance.stubs(:li).returns("")

    render_block_content(block)
  end

  should 'display a link to sitemap with title "View All"' do
    profile = fast_create(Community)
    article = fast_create(TextArticle, profile_id: profile.id)
    block = RecentDocumentsBlock.new
    box = mock
    block.expects(:box).returns(box).at_least_once
    box.expects(:owner).returns(profile.reload).at_least_once

    ActionView::Base.any_instance.stubs(:font_awesome).returns("View all")
    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:profile_image_link).returns("some name")
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

    footer = render_block_footer(block)
    assert_select "a.view-all"
  end

  should "not display link to sitemap when owner is environment" do
    block = RecentDocumentsBlock.new
    box = mock
    block.expects(:box).returns(box).at_least_once
    box.expects(:owner).returns(Environment.new).at_least_once
    assert_equal "", render_block_footer(block)
  end

  should "return articles in api_content" do
    profile = fast_create(Community)
    article = fast_create(TextArticle, profile_id: profile.id)
    block = RecentDocumentsBlock.new
    block.stubs(:owner).returns(profile)
    assert_equal [article.id], block.api_content["articles"].map { |a| a[:id] }
  end

  should "not include link articles if owner is an environment" do
    environment = fast_create(Environment)

    p1 = fast_create(Profile, environment_id: environment.id)
    p2 = fast_create(Profile, environment_id: environment.id)

    doc1 = fast_create(Article, profile_id: p1.id)
    doc2 = fast_create(Article, profile_id: p2.id)
    link = LinkArticle.create!(reference_article: doc1, profile: p2)

    box = Box.new
    box.owner = environment
    box.save!

    block = RecentDocumentsBlock.new
    block.box = box

    all_recent = block.docs
    [doc1, doc2].each do |item|
      assert_includes all_recent, item
    end

    assert_not_includes all_recent, link
  end
end
