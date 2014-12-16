class WorkAssignmentPluginCmsController < CmsController

  def edit_visibility
    @folder = profile.articles.find(params[:article_id])
    @back_to = url_for(@folder.parent.url)
    if request.post?
      @folder.published = params[:article][:published]
      unless params[:q].nil?
        @folder.article_privacy_exceptions = params[:q].split(/,/).map{|n| environment.people.find n.to_i}
        @folder.children.each do |c|
          c.article_privacy_exceptions = params[:q].split(/,/).map{|n| environment.people.find n.to_i}
          c.save!
        end
      end
      @folder.save!
      redirect_to @back_to
    end
  end
end