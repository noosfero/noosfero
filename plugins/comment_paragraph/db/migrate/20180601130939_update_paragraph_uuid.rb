class UpdateParagraphUuid < ActiveRecord::Migration
  def change
    Comment.where('paragraph_uuid IS NOT NULL').find_each do |comment|
      comment.update(paragraph_uuid:  'data-macro-uuid-' + comment.paragraph_uuid)
    end
  end
end
