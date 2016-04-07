class CommentParagraphPlugin::API < Grape::API
  MAX_PER_PAGE = 20

  resource :articles do
    paginate max_per_page: MAX_PER_PAGE
    get ':id/comment_paragraph_plugin/comments' do
      article = find_article(environment.articles, params[:id])
      comments = select_filtered_collection_of(article, :comments, params)
      comments = comments.in_paragraph(params[:paragraph_uuid])
      comments = comments.without_reply if(params[:without_reply].present?)
      present paginate(comments), :with => Noosfero::API::Entities::Comment, :current_person => current_person
    end
  end
end
