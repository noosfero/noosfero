require File.join(Rails.root,'lib','noosfero','api','entities')
module Noosfero
  module API
    module Entities
      class Comment < CommentBase
        expose :paragraph_uuid
        expose :comment_paragraph_selected_area
        expose :comment_paragraph_selected_content
      end
    end
  end
end
