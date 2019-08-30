module CmsHelper
  include ArticleHelper

  def link_to_new_article(mime_type)
    action = mime_type_to_action_name(mime_type) + "_new"
    button("new", _("New %s") % mime_type, action: action, parent_id: params[:parent_id])
  end

  def mime_type_to_action_name(mime_type)
    mime_type.gsub("/", "_").gsub("-", "")
  end

  attr_reader :environment

  def options_for_article(article, tokenized_children = nil)
    article_helper = helper_for_article(article)
    article_helper.custom_options_for_article(article, tokenized_children)
  end

  def link_to_article(article)
    article_name = article.title
    if article.folder?
      link_to font_awesome(article.icon, "#{article_name}/"), action: "view", id: article.id
    else
      if article.image?
        image_tag(icon_for_article(article)) + link_to(article_name, article.url)
      else
        link_to font_awesome(article.icon, article_name), article.url
      end
    end
  end

  def display_spread_button(article)
    expirable_button article, :spread, _("Spread this"), { action: "publish", id: article.id }, { modal: true }
  end

  def display_delete_button(article)
    expirable_button article, :delete, _("Delete"),
                     { action: "destroy", id: article.id }, { :method => :post,
                                                              "data-confirm" => delete_article_message(article) }, :trash
  end

  def expirable_button(content, action, title, url, options = {}, icon = "")
    reason = @plugins.dispatch("content_expire_#{action.to_s}", content).first
    if reason.present?
      options[:class] = (options[:class] || "") + " disabled"
      options[:disabled] = "disabled"
      options.delete("data-confirm")
      options.delete(:method)
      title = reason
    end
    icon = action.to_sym unless icon.present?
    button_without_text icon, title, url, options
  end

  def max_upload_size_for(profile)
    quota = profile.upload_quota.try(:megabytes)
    [quota, UploadedFile.max_size].select { |s| s.present? }.min
  end
end
