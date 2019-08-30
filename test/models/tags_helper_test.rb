# encoding: UTF-8

require_relative "../test_helper"

class TagsHelperTest < ActiveSupport::TestCase
  include ApplicationHelper
  include TagsHelper
  include Rails.application.routes.url_helpers

  def h(s); s; end

  def link_to(text, *args); text; end

  should "order tags alphabetically" do
    result = tag_cloud(
      { "tag1" => 9, "Tag3" => 2, "Tag2" => 2, "aTag" => 2, "beTag" => 2 },
      :id,
      host: "noosfero.org", controller: "test", action: "tag"
    )
    assert_equal %w(aTag beTag tag1 Tag2 Tag3).join("\n"), result
  end

  should "order tags alphabetically with special characters" do
    result = tag_cloud(
      { "area" => 9, "\u00E1rea" => 2, "base" => 2, "b\u00E1se" => 3,
        "A" => 1, "\u00C1" => 1, "zebra" => 1, "zebr\u00E1" => 1 },
      :id,
      host: "noosfero.org", controller: "test", action: "tag"
    )
    result = result.split("\n")
    assert_order ["\u00C1", "\u00E1rea", "b\u00E1se", "zebr\u00E1"], result
    assert_order ["A", "area", "base", "zebra"], result
  end
end
