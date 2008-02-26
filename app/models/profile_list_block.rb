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
    @profile_finder ||= ProfileListBlock::Finder.new(self)
  end

  # Default finder. Finds the most recently added profiles.
  class Finder
    def initialize(block)
      @block = block
    end
    attr_reader :block
    def find
      id_list = self.ids
      result = []
      [block.limit, id_list.size].min.times do
        i = pick_random(id_list.size)
        result << Profile.find(id_list[i])
        id_list.delete_at(i)
      end
      result
    end
    def pick_random(top)
      rand(top)
    end
    def ids
      Profile.connection.select_all('select id from profiles').map { |entry| entry['id'].to_i }
    end
  end

  def profiles
    profile_finder.find
  end

  # the title of the block. Probably will be overriden in subclasses.
  def title
    _('People and Groups')
  end

  def help
    _('Clicking on the people or groups will take you to their home page.')
  end

  def content
    profiles = self.profiles
    title = self.title
    nl = "\n"
    lambda do
      list = profiles.map {|item| content_tag( 'li', profile_image_link(item) ) }.join("\n  ")
      if list.empty?
        list = '<div class="common-profile-list-block-none">'+ _('None') +'</div>'
      else
        list = content_tag( 'ul', nl +'  '+ list + nl )
      end
      '<div class="common-profile-list-block">' +
      nl + block_title(title) + nl + list + nl +
      '</div>'
    end
  end

end
