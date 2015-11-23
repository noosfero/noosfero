module HelpHelper

  Klass = 'hideable-help'

  def hideable_help_text text
    link = link_to_function '', 'help.toggle(this)',
      'data-show' => t('helpers.help.show'), 'data-hide' => t('helpers.help.hide'),
      :class => "#{Klass}-link"

    content_tag('div', text, :class => Klass) + link
  end

end
