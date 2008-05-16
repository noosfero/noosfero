module ProfileHelper

  def display_profile_info(profile)
    table_rows = content_tag( 'tr',
                   content_tag( 'th',
                     "\n" +
                     button( :edit, _('edit your information'), :controller => 'profile_editor', :action => 'edit' ) +
                     "\n",
                   :colspan => 2, :class => 'header' )
                 ) + "\n"
    profile.summary.each do |item|
      name = item[0]
      value = item[1]
      if value.is_a?(Proc)
        value = self.instance_eval(value)
      end
      table_rows << content_tag('tr', content_tag('th', _(name)) + content_tag('td', value))
      table_rows << "\n"
    end

    content_tag(
      'table',
      table_rows,
      :class => 'profile_info'
    )
  end

end
