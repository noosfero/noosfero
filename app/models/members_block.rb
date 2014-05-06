class MembersBlock < ProfileListBlock
  settings_items :show_join_leave_button, :type => :boolean, :default => false

  attr_accessible :show_join_leave_button

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

    proc do
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

  def cache_key(language='en', user=nil)
    logged = ''
    if user
      logged += '-logged-in'
      if user.is_member_of? self.owner
        logged += '-member'
      end
    end
    super + logged
  end

end
