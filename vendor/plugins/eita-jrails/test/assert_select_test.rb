# coding: utf-8

require 'abstract_unit'

class AssertSelectTest < ActionController::TestCase
  Assertion = ActiveSupport::TestCase::Assertion

  class AssertSelectController < ActionController::Base
    def response_with=(content)
      @content = content
    end

    def response_with(&block)
      @update = block
    end

    def rjs
      render :update do |page|
        @update.call page
      end
      @update = nil
    end

    def rescue_action(e)
      raise e
    end
  end

  tests AssertSelectController

  def assert_failure(message, &block)
    e = assert_raise(Assertion, &block)
    assert_match(message, e.message) if Regexp === message
    assert_equal(message, e.message) if String === message
  end

  # With single result.
  def test_assert_select_from_rjs_with_single_result
    render_rjs do |page|
      page.replace_html "test", "<div id=\"1\">foo</div>\n<div id=\"2\">foo</div>"
    end
    assert_select "div" do |elements|
      assert elements.size == 2
      assert_select "#1"
      assert_select "#2"
    end
    assert_select "div#?", /\d+/ do |elements|
      assert_select "#1"
      assert_select "#2"
    end
  end

  # With multiple results.
  def test_assert_select_from_rjs_with_multiple_results
    render_rjs do |page|
      page.replace_html "test", "<div id=\"1\">foo</div>"
      page.replace_html "test2", "<div id=\"2\">foo</div>"
    end
    assert_select "div" do |elements|
      assert elements.size == 2
      assert_select "#1"
      assert_select "#2"
    end
  end

  # With one result.
  def test_css_select_from_rjs_with_single_result
    render_rjs do |page|
      page.replace_html "test", "<div id=\"1\">foo</div>\n<div id=\"2\">foo</div>"
    end
    assert_equal 2, css_select("div").size
    assert_equal 1, css_select("#1").size
    assert_equal 1, css_select("#2").size
  end

  # With multiple results.
  def test_css_select_from_rjs_with_multiple_results
    render_rjs do |page|
      page.replace_html "test", "<div id=\"1\">foo</div>"
      page.replace_html "test2", "<div id=\"2\">foo</div>"
    end

    assert_equal 2, css_select("div").size
    assert_equal 1, css_select("#1").size
    assert_equal 1, css_select("#2").size
  end

  #
  # Test assert_select_rjs.
  #

  def test_assert_select_rjs_for_positioned_insert_should_fail_when_mixing_arguments
    render_rjs do |page|
      page.insert_html :top, "test1", "<div id=\"1\">foo</div>"
      page.insert_html :bottom, "test2", "<div id=\"2\">foo</div>"
    end
    assert_raise(Assertion) {assert_select_rjs :insert, :top, "test2"}
  end

  # Test that we can pick up all statements in the result.
  def test_assert_select_rjs_picks_up_all_statements
    render_rjs do |page|
      page.replace "test", "<div id=\"1\">foo</div>"
      page.replace_html "test2", "<div id=\"2\">foo</div>"
      page.insert_html :top, "test3", "<div id=\"3\">foo</div>"
    end

    found = false
    assert_select_rjs do
      assert_select "#1"
      assert_select "#2"
      assert_select "#3"
      found = true
    end
    assert found
  end

  # Test that we fail if there is nothing to pick.
  def test_assert_select_rjs_fails_if_nothing_to_pick
    render_rjs { }
    assert_raise(Assertion) { assert_select_rjs }
  end

  def test_assert_select_rjs_with_unicode
    # Test that non-ascii characters (which are converted into \uXXXX in RJS) are decoded correctly.

    unicode = "\343\203\201\343\202\261\343\203\203\343\203\210"
    render_rjs do |page|
      page.replace "test", %(<div id="1">#{unicode}</div>)
    end

    assert_select_rjs do
      str = "#1"
      assert_select str, :text => unicode
      assert_select str, unicode
      if str.respond_to?(:force_encoding)
        assert_select str, /\343\203\201..\343\203\210/u
        assert_raise(Assertion) { assert_select str, /\343\203\201.\343\203\210/u }
      else
        assert_select str, Regexp.new("\343\203\201..\343\203\210", 0, 'U')
        assert_raise(Assertion) { assert_select str, Regexp.new("\343\203\201.\343\203\210", 0, 'U') }
      end
    end
  end

  def test_assert_select_rjs_with_id
    # Test that we can pick up all statements in the result.
    render_rjs do |page|
      page.replace "test1", "<div id=\"1\">foo</div>"
      page.replace_html "test2", "<div id=\"2\">foo</div>"
      page.insert_html :top, "test3", "<div id=\"3\">foo</div>"
    end
    assert_select_rjs "test1" do
      assert_select "div", 1
      assert_select "#1"
    end
    assert_select_rjs "test2" do
      assert_select "div", 1
      assert_select "#2"
    end
    assert_select_rjs "test3" do
      assert_select "div", 1
      assert_select "#3"
    end
    assert_raise(Assertion) { assert_select_rjs "test4" }
  end

  def test_assert_select_rjs_for_replace
    render_rjs do |page|
      page.replace "test1", "<div id=\"1\">foo</div>"
      page.replace_html "test2", "<div id=\"2\">foo</div>"
      page.insert_html :top, "test3", "<div id=\"3\">foo</div>"
    end
    # Replace.
    assert_select_rjs :replace do
      assert_select "div", 1
      assert_select "#1"
    end
    assert_select_rjs :replace, "test1" do
      assert_select "div", 1
      assert_select "#1"
    end
    assert_raise(Assertion) { assert_select_rjs :replace, "test2" }
    # Replace HTML.
    assert_select_rjs :replace_html do
      assert_select "div", 1
      assert_select "#2"
    end
    assert_select_rjs :replace_html, "test2" do
      assert_select "div", 1
      assert_select "#2"
    end
    assert_raise(Assertion) { assert_select_rjs :replace_html, "test1" }
  end

  def test_assert_select_rjs_for_chained_replace
    render_rjs do |page|
      page['test1'].replace "<div id=\"1\">foo</div>"
      page['test2'].replace_html "<div id=\"2\">foo</div>"
      page.insert_html :top, "test3", "<div id=\"3\">foo</div>"
    end
    # Replace.
    assert_select_rjs :chained_replace do
      assert_select "div", 1
      assert_select "#1"
    end
    assert_select_rjs :chained_replace, "test1" do
      assert_select "div", 1
      assert_select "#1"
    end
    assert_raise(Assertion) { assert_select_rjs :chained_replace, "test2" }
    # Replace HTML.
    assert_select_rjs :chained_replace_html do
      assert_select "div", 1
      assert_select "#2"
    end
    assert_select_rjs :chained_replace_html, "test2" do
      assert_select "div", 1
      assert_select "#2"
    end
    assert_raise(Assertion) { assert_select_rjs :replace_html, "test1" }
  end

  # Simple remove
  def test_assert_select_rjs_for_remove
    render_rjs do |page|
      page.remove "test1"
    end

    assert_select_rjs :remove, "test1"
  end

  def test_assert_select_rjs_for_remove_offers_useful_error_when_assertion_fails
    render_rjs do |page|
      page.remove "test_with_typo"
    end

    assert_select_rjs :remove, "test1"

  rescue Assertion => e
    assert_equal "No RJS statement that removes 'test1' was rendered.", e.message
  end

  def test_assert_select_rjs_for_remove_ignores_block
    render_rjs do |page|
      page.remove "test1"
    end

    assert_nothing_raised do
      assert_select_rjs :remove, "test1" do
        assert_select "p"
      end
    end
  end

  # Simple show
  def test_assert_select_rjs_for_show
    render_rjs do |page|
      page.show "test1"
    end

    assert_select_rjs :show, "test1"
  end

  def test_assert_select_rjs_for_show_offers_useful_error_when_assertion_fails
    render_rjs do |page|
      page.show "test_with_typo"
    end

    assert_select_rjs :show, "test1"

  rescue Assertion => e
    assert_equal "No RJS statement that shows 'test1' was rendered.", e.message
  end

  def test_assert_select_rjs_for_show_ignores_block
    render_rjs do |page|
      page.show "test1"
    end

    assert_nothing_raised do
      assert_select_rjs :show, "test1" do
        assert_select "p"
      end
    end
  end

  # Simple hide
  def test_assert_select_rjs_for_hide
    render_rjs do |page|
      page.hide "test1"
    end

    assert_select_rjs :hide, "test1"
  end

  def test_assert_select_rjs_for_hide_offers_useful_error_when_assertion_fails
    render_rjs do |page|
      page.hide "test_with_typo"
    end

    assert_select_rjs :hide, "test1"

  rescue Assertion => e
    assert_equal "No RJS statement that hides 'test1' was rendered.", e.message
  end

  def test_assert_select_rjs_for_hide_ignores_block
    render_rjs do |page|
      page.hide "test1"
    end

    assert_nothing_raised do
      assert_select_rjs :hide, "test1" do
        assert_select "p"
      end
    end
  end

  # Simple toggle
  def test_assert_select_rjs_for_toggle
    render_rjs do |page|
      page.toggle "test1"
    end

    assert_select_rjs :toggle, "test1"
  end

  def test_assert_select_rjs_for_toggle_offers_useful_error_when_assertion_fails
    render_rjs do |page|
      page.toggle "test_with_typo"
    end

    assert_select_rjs :toggle, "test1"

  rescue Assertion => e
    assert_equal "No RJS statement that toggles 'test1' was rendered.", e.message
  end

  def test_assert_select_rjs_for_toggle_ignores_block
    render_rjs do |page|
      page.toggle "test1"
    end

    assert_nothing_raised do
      assert_select_rjs :toggle, "test1" do
        assert_select "p"
      end
    end
  end

  # Non-positioned insert.
  def test_assert_select_rjs_for_nonpositioned_insert
    render_rjs do |page|
      page.replace "test1", "<div id=\"1\">foo</div>"
      page.replace_html "test2", "<div id=\"2\">foo</div>"
      page.insert_html :top, "test3", "<div id=\"3\">foo</div>"
    end
    assert_select_rjs :insert_html do
      assert_select "div", 1
      assert_select "#3"
    end
    assert_select_rjs :insert_html, "test3" do
      assert_select "div", 1
      assert_select "#3"
    end
    assert_raise(Assertion) { assert_select_rjs :insert_html, "test1" }
  end

  # Positioned insert.
  def test_assert_select_rjs_for_positioned_insert
    render_rjs do |page|
      page.insert_html :top, "test1", "<div id=\"1\">foo</div>"
      page.insert_html :bottom, "test2", "<div id=\"2\">foo</div>"
      page.insert_html :before, "test3", "<div id=\"3\">foo</div>"
      page.insert_html :after, "test4", "<div id=\"4\">foo</div>"
    end
    assert_select_rjs :insert, :top do
      assert_select "div", 1
      assert_select "#1"
    end
    assert_select_rjs :insert, :bottom do
      assert_select "div", 1
      assert_select "#2"
    end
    assert_select_rjs :insert, :before do
      assert_select "div", 1
      assert_select "#3"
    end
    assert_select_rjs :insert, :after do
      assert_select "div", 1
      assert_select "#4"
    end
    assert_select_rjs :insert_html do
      assert_select "div", 4
    end
  end

  def test_assert_select_rjs_raise_errors
    assert_raise(ArgumentError) { assert_select_rjs(:destroy) }
    assert_raise(ArgumentError) { assert_select_rjs(:insert, :left) }
  end

  # Simple selection from a single result.
  def test_nested_assert_select_rjs_with_single_result
    render_rjs do |page|
      page.replace_html "test", "<div id=\"1\">foo</div>\n<div id=\"2\">foo</div>"
    end

    assert_select_rjs "test" do |elements|
      assert_equal 2, elements.size
      assert_select "#1"
      assert_select "#2"
    end
  end

  # Deal with two results.
  def test_nested_assert_select_rjs_with_two_results
    render_rjs do |page|
      page.replace_html "test", "<div id=\"1\">foo</div>"
      page.replace_html "test2", "<div id=\"2\">foo</div>"
    end

    assert_select_rjs "test" do |elements|
      assert_equal 1, elements.size
      assert_select "#1"
    end

    assert_select_rjs "test2" do |elements|
      assert_equal 1, elements.size
      assert_select "#2"
    end
  end

  def test_assert_select_rjs_for_redirect_to
    render_rjs do |page|
      page.redirect_to '/'
    end
    assert_select_rjs :redirect, '/'
  end

  protected
    def render_html(html)
      @controller.response_with = html
      get :html
    end

    def render_rjs(&block)
      @controller.response_with(&block)
      get :rjs
    end

    def render_xml(xml)
      @controller.response_with = xml
      get :xml
    end
end
