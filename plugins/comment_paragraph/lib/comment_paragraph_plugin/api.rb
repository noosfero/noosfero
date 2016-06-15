require_relative 'comments_report'

# Can't be called Api as will result in:
# warning: toplevel constant Api referenced by CommentParagraphPlugin::Api
# To fix this CommentParagraphPlugin should be a module
class CommentParagraphPlugin::API < Grape::API

  MAX_PER_PAGE = 20

  helpers CommentParagraphPlugin::CommentsReport

  resource :articles do
    paginate max_per_page: MAX_PER_PAGE
    get ':id/comment_paragraph_plugin/comments' do
      article = find_article(environment.articles, params[:id])
      comments = select_filtered_collection_of(article, :comments, params)
      comments = comments.without_spam
      comments = comments.in_paragraph(params[:paragraph_uuid])
      comments = comments.without_reply if(params[:without_reply].present?)
      present paginate(comments), :with => Api::Entities::Comment, :current_person => current_person
    end

    {activate: true, deactivate: false}.each do |method, value|
      post ":id/comment_paragraph_plugin/#{method}" do
        authenticate!
        article = find_article(environment.articles, params[:id])
        return forbidden! unless article.comment_paragraph_plugin_enabled? && article.allow_edit?(current_person)
        article.comment_paragraph_plugin_activate = value
        article.save!
        present_partial article, :with => Api::Entities::Article
      end
    end

    get ':id/comment_paragraph_plugin/comments/count' do
      article = find_article(environment.articles, params[:id])
      comments = select_filtered_collection_of(article, :comments, params)
      comments.group(:paragraph_uuid).count
    end

    get ":id/comment_paragraph_plugin/export" do
      article = find_article(environment.articles, params[:id])
      result = export_comments_csv(article)
      filename = "comments_for_article#{article.id}_#{DateTime.now.to_i}.csv"
      content_type 'text/csv; charset=UTF-8; header=present'
      env['api.format'] = :binary # there's no formatter for :binary, data will be returned "as is"
      header 'Content-Disposition', "attachment; filename*=UTF-8''#{CGI.escape(filename)}"
      result
    end

  end
end
