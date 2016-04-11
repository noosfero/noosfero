class CommentParagraphPlugin::API < Grape::API
  MAX_PER_PAGE = 20

  resource :articles do
    paginate max_per_page: MAX_PER_PAGE
    get ':id/comment_paragraph_plugin/comments' do
      article = find_article(environment.articles, params[:id])
      comments = select_filtered_collection_of(article, :comments, params)
      comments = comments.without_spam
      comments = comments.in_paragraph(params[:paragraph_uuid])
      comments = comments.without_reply if(params[:without_reply].present?)
      present paginate(comments), :with => Noosfero::API::Entities::Comment, :current_person => current_person
    end

    {activate: true, deactivate: false}.each do |method, value|
      post ":id/comment_paragraph_plugin/#{method}" do
        authenticate!
        article = find_article(environment.articles, params[:id])
        return forbidden! unless article.comment_paragraph_plugin_enabled? && article.allow_edit?(current_person)
        article.comment_paragraph_plugin_activate = value
        article.save!
        present_partial article, :with => Noosfero::API::Entities::Article
      end
    end

    get ':id/comment_paragraph_plugin/comments/count' do
      article = find_article(environment.articles, params[:id])
      comments = select_filtered_collection_of(article, :comments, params)
      comments.group(:paragraph_uuid).count
    end
  end
end
