class WorkAssignmentPluginMyprofileController < MyProfileController

include ArticleHelper
include CmsHelper

before_filter :protect_if, :only => [:edit_visibility]


def protect_if
  article = c.environment.articles.find_by_id(c.params[:article_id])
  (user && !article.nil? && (user.is_member_of? article.profile) &&
  article.parent.allow_privacy_edition && article.folder? &&
  (article.author == user || user.has_permission?('view_private_content', profile)))
end 

def edit_privacy
  unless params[:article_id].blank?
    folder = profile.environment.articles.find_by_id(params[:article_id])
    @back_to = url_for(folder.parent.url)
    unless params[:article].blank?
      folder.published = params[:article][:published]
      unless params[:q].nil?
        folder.article_privacy_exceptions = params[:q].split(/,/).map{|n| environment.people.find n.to_i}
      end
      folder.save!
      redirect_to @back_to
    end    
  end
 end
end