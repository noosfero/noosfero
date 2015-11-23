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
    if WorkAssignmentPlugin.is_submission?(self)
      related_work_assignment = self.parent.parent

      if(!related_work_assignment.publish_submissions)
        self.show_to_followers = false
      end

      self.published = self.parent.published
    end
  end
end