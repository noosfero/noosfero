class ProfileListBlock < Block

  settings_items :limit, :type => :integer, :default => 6

  def self.description
    _('Random profiles')
  end

  # override in subclasses!
  def profiles
    owner.profiles
  end

  def profile_list
    random = Noosfero::SQL.random_function
    profiles.visible.all(:limit => limit, :select => 'DISTINCT profiles.*, ' + random, :order => random)
  end

  def profile_count
    profiles.visible.count
  end

  # the title of the block. Probably will be overriden in subclasses.
  def default_title
    _('{#} People or Groups')
  end

  def help
    _('Clicking on the people or groups will take you to their home page.')
  end

  def content
    profiles = self.profile_list
    title = self.view_title
    nl = "\n"
    link_method = profile_image_link_method
    lambda do
      count=0
      list = profiles.map {|item|
               count+=1
               send(link_method, item ) #+
             }.join("\n  ")
      if list.empty?
        list = '<div class="common-profile-list-block-none">'+ _('None') +'</div>'
      else
        list = content_tag 'ul', nl +'  '+ list + nl
      end
      block_title(title) + nl +
      '<div class="common-profile-list-block">' +
      nl + list + nl + '<br style="clear:both" /></div>'
    end
  end

  def profile_image_link_method
    :profile_image_link
  end

  def view_title
    title.gsub('{#}', profile_count.to_s)
  end

end
