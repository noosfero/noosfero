require_relative "../test_helper"

class ModalHelperTest < ActionView::TestCase
  include ModalHelper

  should "provide the needed files" do
    assert File.exists?(Rails.root.join("public", "stylesheets", "vendor", "colorbox.css")), "colorbox.css expected to be in public/stylesheets, but not found"
    assert File.exists?(Rails.root.join("public", "javascripts", "vendor", "jquery.colorbox-min.js")), "jquery.colorbox-min.js expected to be in public/javascripts, but not found"
  end

  should "provide link to close modal" do
    expects(:button).with(:cancel, "text", "#!",
                          has_entries(class: " modal-close",
                                      id: "my-id")).returns("[close-modal]")

    assert_equal "[close-modal]", modal_close_button("text", id: "my-id")
  end

  should "merge existing :class option in modal_close_button" do
    expects(:button).with(:cancel, "text", "#!",
                          has_entries(class: " modal-close my-class",
                                      id: "my-id")).returns("[close-modal]")

    assert_equal "[close-modal]", modal_close_button("text", class: "my-class", id: "my-id")
  end

  should "provide modal_button" do
    expects(:button).with("type", "label", { action: "popup" }, has_entries(class: "open-modal")).returns("[button]")

    assert_equal "[button]", modal_button("type", "label", action: "popup")
  end

  should "provide modal_icon_button" do
    expects(:button_without_text).with("type", "label", { action: "popup" }, has_entries(class: "open-modal")).returns("[button]")

    assert_equal "[button]", modal_icon_button("type", "label", action: "popup")
  end
end
