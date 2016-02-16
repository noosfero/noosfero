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

