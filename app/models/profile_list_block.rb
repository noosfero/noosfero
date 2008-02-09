class ProfileListBlock < Block

  settings_items :limit, :default => 6

  def self.description
    _('A block that displays random profiles')
  end

  # Override this method to make the block list specific types of profiles
  # instead of anyone.
  #
  # In this class this method just returns <tt>Profile</tt> (the class). In
  # subclasses you could return <tt>Person</tt>, for instance, if you only want
  # to list people, or <tt>Organization</tt>, if you want organizations only.
  #
  # You don't need to return only classes. You can for instance return an
  # association array from a has_many ActiveRecord association, for example.
  # Actually the only requirement for the object returned by this method is to
  # have a <tt>find</tt> method that accepts the same interface as the
  # ActiveRecord::Base's find method .
  def profile_finder
    Profile
  end

  def profiles
    # FIXME pick random people instead
    finder = profile_finder
    options = { :limit => self.limit, :order => 'created_at desc' } 
    if finder.is_a?(Class)
      finder.find(:all, options)
    else
      finder.find(options)
    end
  end

  def random(top)
    Kernel.rand(top)
  end

  # the title of the block. Probably will be overriden in subclasses.
  def title
    _('People and Groups')
  end

  def content
    profiles = self.profiles
    title = self.title
    lambda do
      block_title(title) +
      profiles.map {|item| content_tag('div', profile_image_link(item)) }.join("\n")
    end
  end

end
