class WorkAssignmentPlugin::WorkAssignment < Folder

  after_save do |work_assignment|
    work_assignment.children.select {|child| child.kind_of?(UploadedFile)}.each do |submission|
      author_folder = work_assignment.find_or_create_author_folder(submission.author)
      submission.name = versioned_name(submission, author_folder) if !(submission.name =~ /\(V[0-9]*\)/)
      submission.parent = author_folder
      submission.save!
    end
  end

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
    children.find_by_slug(author.identifier) || Folder.create!(:name => author.name, :slug => author.identifier, :parent => self, :profile => profile)
  end

  def submissions
    children.map(&:children).flatten.compact
  end

end
