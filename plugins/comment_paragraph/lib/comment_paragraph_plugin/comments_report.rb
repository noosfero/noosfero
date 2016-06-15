require 'csv'

module CommentParagraphPlugin::CommentsReport

  def export_comments_csv(article)
    comments_map = article.comments.group_by { |comment| comment.paragraph_uuid }
    @export = []
    doc =  Nokogiri::HTML(article.body)
    paragraph_id = 1
    doc.css("[data-macro-paragraph_uuid]").map do |paragraph|
      uuid = paragraph.attributes['data-macro-paragraph_uuid'].value
      comments_for_paragraph = comments_map[uuid]
      if comments_for_paragraph
        # Put comments for the paragraph
        comments_for_paragraph.each do | comment |
          @export << create_comment_element(comment, paragraph, paragraph_id)
        end
      else # There are no comments for this paragraph
        @export << create_comment_element(nil, paragraph, paragraph_id)
      end
      paragraph_id += 1
    end
    # Now we need to put all other comments that are not attached to a paragraph
    comments_without_paragrah = comments_map[nil] || []
    comments_without_paragrah.each do | comment |
      @export << create_comment_element(comment, nil, nil)
    end
    return _("No comments for article[%{id}]: %{path}\n\n") % {:id => article.id, :path => article.path} if @export.empty?

    column_names = @export.first.keys
    CSV.generate(force_quotes: true) do |csv|
      csv << column_names
      @export.each { |x| csv << x.values }
    end
  end

  private

  def create_comment_element(comment, paragraph, paragraph_id)
    {
      paragraph_id: paragraph_id,
      paragraph_text: paragraph.present? ? paragraph.text.strip : nil,
      comment_id: comment.present? ? comment.id : '-',
      comment_reply_to: comment.present? ? comment.reply_of_id : '-',
      comment_title: comment.present? ? comment.title : '-',
      comment_content: comment.present? ? comment.body : '-',
      comment_author_name: comment.present? ? comment.author_name : '-',
      comment_author_email: comment.present? ? comment.author_email : '-'
    }
  end

end
