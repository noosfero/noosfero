module CmsHelper

  def link_to_new_article(mime_type)
    action = mime_type_to_action_name(mime_type) + '_new'
    button('new', _("New %s") % mime_type, :action => action, :parent_id => params[:parent_id])
  end

  def mime_type_to_action_name(mime_type)
    mime_type.gsub('/', '_').gsub('-', '')
  end

  def add_upload_file_field(name, locals)
    button_to_function :add, name, nil do |page|
      page.insert_html :bottom, :uploaded_files, :partial => 'upload_file', :locals => locals, :object => UploadedFile.new
    end
  end

  def pagination_links(collection, options={})
    options = {:previous_label => '&laquo; ', :next_label => ' &raquo;', :page_links => false}.merge(options)
    will_paginate(collection, options)
  end

  attr_reader :environment

  def options_for_article(article)
    article_helper = helper_for_article(article)
    article_helper.custom_options_for_article(article)
  end

  def link_to_article(article)
    article_name = article.title
    if article.folder?
      link_to article_name, {:action => 'view', :id => article.id}, :class => icon_for_article(article)
    else
      if article.image?
        image_tag(icon_for_article(article)) + link_to(article_name, article.url)
      else
        link_to article_name, article.url, :class => icon_for_article(article)
      end
    end
  end

  def display_spread_button(profile, article)
    if profile.person?
      expirable_button article, :spread, _('Spread this'), :action => 'publish', :id => article.id
    elsif profile.community? && environment.portal_community
      expirable_button article, :spread, _('Spread this'), :action => 'publish_on_portal_community', :id => article.id
    end
  end

  def display_delete_button(article)
    expirable_button article, :delete, _('Delete'), { :action => 'destroy', :id => article.id }, :method => :post, :confirm => delete_article_message(article)
  end

  def expirable_button(content, action, title, url, options = {})
    reason = @plugins.dispatch("content_expire_#{action.to_s}", content).first
    if reason.present?
      options[:class] = (options[:class] || '') + ' disabled'
      options[:disabled] = 'disabled'
      options.delete(:confirm)
      options.delete(:method)
      title = reason
    end
    button_without_text action.to_sym, title, url, options
  end
end
