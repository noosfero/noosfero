class MoveCommentGroupToCommentParagraph < ActiveRecord::Migration[5.1]

  def change
    if column_exists? :comments, :group_id

      Comment.where("group_id IS NOT NULL").find_each do |comment|
        comment.update(paragraph_uuid:  'data-macro-uuid-' + comment.group_id.to_s)
      end
  
      Article.where(:id => Comment.where("group_id IS NOT NULL").pluck(:source_id).uniq).find_each do |article|
        article.body.gsub!(/<div class="macro article_comments" data-macro="comment_group_plugin\/allow_comment" data-macro-id="([0-9]+)">\r\n<p>(.*)<\/p>\r\n<\/div>/, '<p><span class="macro article_comments paragraph_comment " data-macro="comment_paragraph_plugin/allow_comment" id="data-macro-uuid-\1">\2</span></p>')
        article.type='CommentParagraphPlugin::Discussion'
        article.start_date = article.created_at
        article.save!
      end
  
      remove_column :comments, :group_id
    end
  end

end
