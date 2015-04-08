require 'loofah/helpers'

ActionView::Base.full_sanitizer = Loofah::Helpers::ActionView::FullSanitizer.new
ActionView::Base.white_list_sanitizer = Loofah::Helpers::ActionView::WhiteListSanitizer.new

Loofah::HTML5::WhiteList::ALLOWED_ELEMENTS_WITH_LIBXML2.merge %w[
  img object embed param table tr th td applet comment iframe audio video source
]

Loofah::HTML5::WhiteList::ALLOWED_ATTRIBUTES.merge %w[
  align border alt vspace hspace width heigth value type data
  style target codebase archive classid code flashvars scrolling frameborder controls autoplay colspan
]

# do not escape COMMENT_NODE
require 'loofah/scrubber'
module Loofah
  class Scrubber
    private

    def html5lib_sanitize node
      case node.type
      when Nokogiri::XML::Node::ELEMENT_NODE
        if HTML5::Scrub.allowed_element? node.name
          HTML5::Scrub.scrub_attributes node
          return Scrubber::CONTINUE
        end
      when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE,Nokogiri::XML::Node::COMMENT_NODE
        return Scrubber::CONTINUE
      end
      Scrubber::STOP
    end

  end
end
