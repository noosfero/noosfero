require_dependency 'article'
require_dependency 'folder'

class Folder < Article
  after_save do |folder|
    if folder.parent.kind_of?(WorkAssignmentPlugin::WorkAssignment)
      folder.children.each do |c|
        c.published = folder.published
        c.article_privacy_exceptions = folder.article_privacy_exceptions
      end
    end
  end
end
