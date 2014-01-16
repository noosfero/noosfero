class MembersBlock < ProfileListBlock
  settings_items :show_join_leave_button, :type => :boolean, :default => false

  def self.description
    _('Members')
  end

  def default_title
    _('{#} members')
  end

  def help
    _('This block presents the members of a collective.')
  end

  def footer
    profile = self.owner
    show_button_block = show_join_leave_button

    lambda do
      if show_button_block
        @view_all = link_to _('View all'), :profile => profile.identifier, :controller => 'profile', :action => 'members'
        render "blocks/profile_info_actions/join_leave_community"
      else
        link_to _('View all'), :profile => profile.identifier, :controller => 'profile', :action => 'members'
      end
    end
  end

  def profiles
    owner.members
  end

  def extra_option
    data = {
      :human_name => _("Show join leave button"),
      :name => 'block[show_join_leave_button]',
      :value => true,
      :checked => show_join_leave_button,
      :options => {}
    }
  end

end