ActionView::Base.sanitized_allowed_attributes += ['data-macro']

class VariablesPlugin::Profile < Noosfero::Plugin::Macro

  def self.configuration
    {
      :title => _('Variables'),
      :skip_dialog => false,
      :generator => method(:macro_default_generator),
      :params => [
        {
          :name   => 'variable',
          :label  => _('Select the desired variable'),
          :type   => 'select',
          :values => ['{profile}', '{name}']
        }
      ],
    }
  end

  def self.macro_default_generator(macro)
    "
      '<div class=\"macro mceNonEditable\" data-macro=\"#{macro.identifier}\">'
      + jQuery('*[name=variable]', dialog).val()
      + '</div>';
    "
  end

  def parse(params, inner_html, source)
    if context.profile
      inner_html.gsub!(/\{profile\}/, context.profile.identifier)
      inner_html.gsub!(/\{name\}/, context.profile.name)
    end
    inner_html
  end

end
