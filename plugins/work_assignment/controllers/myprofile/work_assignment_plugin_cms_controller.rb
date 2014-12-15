class WorkAssignmentPluginCmsController < CmsController

  def edits
    @folder = profile.articles.find(params[:article_id])
    @back_to = url_for(@folder.parent.url)
    if request.post?
      @folder.published = params[:article][:published]
      unless params[:q].nil?
        @folder.article_privacy_exceptions = params[:q].split(/,/).map{|n| environment.people.find n.to_i}
      end
      @folder.save!
      redirect_to @back_to
      x = Article.find_by_id(@folder.id)
      puts "a"*55
      puts "#{x.published?}"
    end
  end
end