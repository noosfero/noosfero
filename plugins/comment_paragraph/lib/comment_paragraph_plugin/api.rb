require_relative "comments_report"

# Can't be called Api as will result in:
# warning: toplevel constant Api referenced by CommentParagraphPlugin::Api
# To fix this CommentParagraphPlugin should be a module
class CommentParagraphPlugin::API < Grape::API::Instance
  MAX_PER_PAGE = 20

  helpers CommentParagraphPlugin::CommentsReport

  resource :articles do
    paginate max_per_page: MAX_PER_PAGE
    get ":id/comment_paragraph_plugin/comments" do
      article = find_article(environment.articles, params)
      comments = select_filtered_collection_of(article, :comments, params)
      comments = comments.without_spam
      comments = comments.in_paragraph(params[:paragraph_uuid])
      comments = comments.without_reply if (params[:without_reply].present?)
      present paginate(comments), with: Api::Entities::Comment, current_person: current_person
    end

    get ":id/comment_paragraph_plugin/comments/count" do
      article = find_article(environment.articles, params)
      comments = select_filtered_collection_of(article, :comments, params)
      comments.group(:paragraph_uuid).count
    end

    get ":id/comment_paragraph_plugin/export" do
      article = find_article(environment.articles, params)
      result = export_comments_csv(article)
      filename = "#{article.slug}_#{DateTime.now.strftime("%Y%m%d%H%M")}.csv"
      content_type "text/csv; charset=UTF-8; header=present"
      header "Cache-Control", "no-cache, must-revalidate, post-check=0, pre-check=0"
      header "Content-Disposition", "attachment; filename=#{CGI.escape(filename)}"
      { data: result }
    end
  end
end
