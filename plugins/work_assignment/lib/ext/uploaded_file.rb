require_dependency 'article'
require_dependency 'uploaded_file'

class UploadedFile < Article
  after_save do |uploaded_file|
    if uploaded_file.parent.kind_of?(WorkAssignmentPlugin::WorkAssignment)
      author_folder = uploaded_file.parent.find_or_create_author_folder(uploaded_file.author)
      uploaded_file.name = WorkAssignmentPlugin::WorkAssignment.versioned_name(uploaded_file, author_folder)
      uploaded_file.parent = author_folder
      logger.info("\n\n==> #{uploaded_file.name}\n\n")
      uploaded_file.save!
    end
  end
end
