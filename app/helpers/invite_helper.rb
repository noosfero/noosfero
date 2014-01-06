module InviteHelper
  def plugins_options
    @plugins.dispatch(:search_friend_fields)
  end

  def search_friend_fields
    labels = [
      _('Name'),
      _('Username'),
      _('Email'),
    ] + plugins_options.map { |options| options[:name] }

    last = labels.pop
    label = labels.join(', ')
    "#{label} #{_('or')} #{last}"
  end
end
