require_dependency 'search_helper'

module SubOrganizationsPlugin::SearchHelper

  include SearchHelper

  def display_selectors(display, float = 'right')
    display = 'compact' if display.blank?
    compact_link = display == 'compact' ? c_('Compact') : link_to(c_('Compact'), params.merge(:display => 'compact'))
    full_link = display == 'full' ? c_('Full') : link_to(c_('Full'), params.merge(:display => 'full'))
    content_tag('div',
      content_tag('strong', c_('Display')) + ': ' + [compact_link,full_link].compact.join(' | ').html_safe,
      :class => 'search-customize-options'
    )
  end


end
