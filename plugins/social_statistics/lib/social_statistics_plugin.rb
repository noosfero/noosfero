class SocialStatisticsPlugin < Noosfero::Plugin

  def self.plugin_name
    _("Social Statistics")
  end

  def self.plugin_description
    _("Provides customized social statistics graphs and checks.")
  end

  def reserved_identifiers
    ['stats']
  end

  def user_menu_items(user)
    if user.is_admin?
      proc do
        { :title => _('Stats'),
          :icon => 'pie-chart',
          :url => '/stats',
          :html_options =>
            { :title => _("Manage the environment statistics."),
              :target => '_blank'
            }
        }
      end
    end
  end

end
