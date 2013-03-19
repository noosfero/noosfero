class WorkAssignmentPlugin::WorkAssignment < Folder

  settings_items :publish_submissions, :type => :boolean, :default => false

  def self.icon_name(article = nil)
    'work-assignment'
  end

  def self.short_description
    _('Work Assignment')
  end

  def self.description
    _('Defines a work to be done by the members and receives their submissions about this work.')
  end

  def self.versioned_name(submission, folder)
    "(V#{folder.children.count + 1}) #{submission.name}"
  end

  def accept_comments?
    true
  end

  def allow_create?(user)
    profile.members.include?(user)
  end

  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/work_assignment.html.erb'
    end
  end

  def find_or_create_author_folder(author)
    children.find_by_slug(author.identifier.to_slug) || Folder.create!(:name => author.name, :slug => author.identifier.to_slug, :parent => self, :profile => profile)
  end

  def submissions
    children.map(&:children).flatten.compact
  end

  def cache_key_with_person(params = {}, user = nil, language = 'en')
    cache_key_without_person + (user && profile.members.include?(user) ? "-#{user.identifier}" : '')
  end
  alias_method_chain :cache_key, :person

end
