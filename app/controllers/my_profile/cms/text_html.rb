class CmsController

  def text_html_new
    @article = Article.new(params[:article])
    if params[:parent_id]
      @article.parent = profile.articles.find(params[:parent_id])
    end
    @article.profile = profile
    if request.post?
      if @article.save
        redirect_to :action => 'view', :id => @article.id
      end
    end
  end

  def text_html_edit
    @article = Article.find(params[:id])
    if request.post?
      if @article.update_attributes(params[:article])
        redirect_to :action => 'view', :id => @article.id
      end
    end
  end

end
