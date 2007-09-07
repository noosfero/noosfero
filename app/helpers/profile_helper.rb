module ProfileHelper

  def display_profile_info(profile)
    info = profile.info
    if info.nil?
      content_tag('div', _('This profile does not have any public information'))
    else
      table_rows = ''
      info.each do |item|
        name = item[0]
        value = item[1]
        if value.is_a?(Proc)
          value = self.instance_eval(value)
        end

        table_rows << content_tag('tr', content_tag('th', name) + content_tag('td', value))
        table_rows << "\n"
      end

      content_tag(
        'table',
        table_rows,
        :class => 'profile_info'
      )
    end
  end

end
