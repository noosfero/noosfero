require_dependency 'article'

class Article
  before_validation :work_assignment_save_into_author_folder
  after_validation :work_assignment_change_visibility

  def work_assignment_save_into_author_folder
    if not self.is_a? Folder and self.parent.kind_of? WorkAssignmentPlugin::WorkAssignment
      author_folder = self.parent.find_or_create_author_folder(self.author)
      self.name = WorkAssignmentPlugin::WorkAssignment.versioned_name(self, author_folder)
      self.parent = author_folder
    end
  end

  def work_assignment_change_visibility
    if self.parent && self.parent.parent && self.parent.parent.kind_of?(WorkAssignmentPlugin::WorkAssignment)
      self.published = self.parent.published
    end
  end
end