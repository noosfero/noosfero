require_dependency 'api/entities'

module API
  module Entities
    class Comment < CommentBase
      expose :paragraph_uuid
      expose :comment_paragraph_selected_area
      expose :comment_paragraph_selected_content
    end
  end
end
