module EnterpriseHomepageHelper

  def display_profile_info(profile)
    data = ''
    [
      [ _('Contact person:'),    :contact_person    ],
      [ _('e-Mail:'),            :contact_email     ],
      [ _('Phone(s):'),          :contact_phone     ],
      [ _('Location:'),          :location          ],
      [ _('Address:'),           :address           ],
      [ _('Economic activity:'), :economic_activity ]
    ].each { | name, att |
      if profile.send( att ) and not profile.send( att ).blank?
        data << content_tag( 'li', content_tag('strong', name) +' '+ profile.send( att ).to_s ) +"\n"
      end
    }
    if profile.respond_to?(:distance) and !profile.distance.nil?
      data << content_tag( 'li',
                           content_tag('strong',_('Distance:')) +' '+
                           "%.2f%" % profile.distance
                         ) + "\n"
    end
    content_tag('div', content_tag('ul', data), :class => 'enterprise-info')
  end
end
