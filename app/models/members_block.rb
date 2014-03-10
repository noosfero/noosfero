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
    s = show_join_leave_button

    lambda do
      render :file => 'blocks/members', :locals => { :profile => profile, :show_join_leave_button => s}
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
