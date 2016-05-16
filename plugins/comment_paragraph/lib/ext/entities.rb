require_dependency 'api/entities'

module Api
  module Entities
    class Comment
      expose :paragraph_uuid
      expose :comment_paragraph_selected_area
      expose :comment_paragraph_selected_content
    end
  end
end
