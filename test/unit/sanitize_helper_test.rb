require_relative "../test_helper"

class SanitizeHelperTest < ActionView::TestCase

  should 'permit white_list attributes on links' do
    allowed_attributes.each do |attribute|
      assert_match /#{attribute}/, sanitize_link("<a #{attribute.to_sym}='value' />")
    end
  end
end
