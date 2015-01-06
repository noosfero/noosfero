require_dependency 'cms_controller'

class CmsController


protect_if :only => :edit_visibility do |c,user,profile|
  profile.articles.find(c.params[:article_id]).author == user || user.has_permission?('view_private_content', profile)
end

def edit_visibility
  unless params[:article_id].blank?
    @folder = profile.articles.find(params[:article_id])
    @back_to = url_for(@folder.parent.url)
    unless params[:article].blank?
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

def self.add_as_exception?(action)
    actions = "edit_visibility, search_article_privacy_exceptions"

    if actions.include? action
      true
    else
      false
    end
  end

end