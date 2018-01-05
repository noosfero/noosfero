module ArticleHelper

  include TokenHelper
  include FormsHelper

  def article_reported_version(article)
    search_path = Rails.root.join('app', 'views', 'shared', 'reported_versions')
    partial_path = File.join('shared', 'reported_versions', 'profile', partial_for_class_in_view_path(article.class, search_path))
    render_to_string(:partial => partial_path, :locals => {:article => article})
  end

  def custom_options_for_article(article, tokenized_children)
    @article = article

    visibility_options(@article, tokenized_children) +
    topic_creation(@article) +
    content_tag('h4', _('Options')) +
    content_tag('div',
      content_tag(
        'div',
        check_box(:article, :archived) +
        content_tag('label', _('Do not allow new content on this article and its children'), :for => 'article_archived_true')
      ) +

      (article.profile.has_members? ?
      content_tag(
        'div',
        check_box(:article, :allow_members_to_edit) +
        content_tag('label', _('Allow all members to edit this article'), :for => 'article_allow_members_to_edit')
      ) :
      '') +

      content_tag(
        'div',
        check_box(:article, :accept_comments) +
        content_tag('label', (article.parent && article.parent.forum? ? _('This topic is opened for replies') : _('I want to receive comments about this article')), :for => 'article_accept_comments')
      ) +

      content_tag(
        'div',
        check_box(:article, :notify_comments) +
        content_tag('label', _('I want to receive a notification of each comment written by e-mail'), :for => 'article_notify_comments') +
        observe_field(:article_accept_comments, :function => "jQuery('#article_notify_comments')[0].disabled = ! jQuery('#article_accept_comments')[0].checked;jQuery('#article_moderate_comments')[0].disabled = ! jQuery('#article_accept_comments')[0].checked")
      ) +

      content_tag(
        'div',
        check_box(:article, :moderate_comments) +
        content_tag('label', _('I want to approve comments on this article'), :for => 'article_moderate_comments')
      ) +

      (article.can_display_hits? ?
      content_tag(
        'div',
        check_box(:article, :display_hits) +
        content_tag('label', _('I want this article to display the number of hits it received'), :for => 'article_display_hits')
      ) : '') +

      (article.can_display_versions? ?
      content_tag(
        'div',
        check_box(:article, :display_versions) +
        content_tag('label', _('I want this article to display a link to older versions'), :for => 'article_display_versions')
      ) : '') +

      (self.respond_to?(:extra_options) ? self.extra_options : "")
    )
  end

  def visibility_options(article, tokenized_children)
    content_tag('h4', _('Visibility')) +
    content_tag('div',
      content_tag('div',
        radio_button(:article, :published, true) +
          content_tag('span', '&nbsp;'.html_safe, :class => 'access-public-icon') +
          content_tag('label', _('Public'), :for => 'article_published_true') +
          content_tag('span', _('Visible to other people'), :class => 'access-note'),
          :class => 'access-item'
           ) +
      content_tag('div',
        radio_button(:article, :published, false) +
          content_tag('span', '&nbsp;'.html_safe, :class => 'access-private-icon') +
          content_tag('label', _('Private'), :for => 'article_published_false', :id => "label_private") +
          content_tag('span', _('Limit visibility of this article'), :class => 'access-note'),
          :class => 'access-item'
      ) +
      privacity_exceptions(article, tokenized_children),
      :class => 'access-itens'
    )
  end

  def topic_creation(article)
    return '' unless article.forum?

    content_tag('h4', _('Topic creation')) +
    content_tag( 'small', _('Who will be able to create new topics on this forum?')) +
    access_slider_field_tag('topic-creation', 'article[topic_creation]', article.profile, article.topic_creation, article.topic_creation_access)
  end

  def privacity_exceptions(article, tokenized_children)
    content_tag('div',
      content_tag('div',
        (
          if article.profile
            add_option_to_followers(article, tokenized_children)
          else
            ''
          end
        )
      ),
      :style => "margin-left:10px"
    )
  end

  def add_option_to_followers(article, tokenized_children)
    label_message = article.profile.organization? ? _('Allow all community members to view this content') : _('Allow all your friends to view this content')

    check_box(
      :article,
      :show_to_followers,
      {:class => "custom_privacy_option"}
    ) +
    content_tag(
      'label',
      label_message,
      :for => 'article_show_to_followers',
      :id => 'label_show_to_followers'
    ) +
    (article.profile.community? ?
      content_tag(
        'div',
        content_tag(
          'label',
          _('Allow only community members entered below to view this content'),
          :id => "text-input-search-exception-users"
        ) +
        token_input_field_tag(
          :q,
          'search-article-privacy-exceptions',
          {:action => 'search_article_privacy_exceptions'},
          {
            :focus => false,
            :hint_text => _('Type in a name of a community member'),
            :pre_populate => tokenized_children
          }
        )
      ) : '')
  end

  def prepare_to_token_input(array)
    array.map { |object| {:id => object.id, :name => object.name} }
  end

  def prepare_to_token_input_by_label(array)
    array.map { |object| {:label => object.name, :value => object.name} }
  end

  def prepare_to_token_input_by_class(array)
    array.map { |object| {:id => "#{object.class.name}_#{object.id || object.name}", :name => "#{object.name} (#{_(object.class.name)})", :class => object.class.name}}
  end

  def cms_label_for_new_children
    _('New article')
  end

  def cms_label_for_edit
    _('Edit')
  end

  def follow_button_text(article)
    font_awesome(:plus, article.event? ? _('Attend') : _('Follow'))
  end

  def unfollow_button_text(article)
    font_awesome(:minus, article.event? ? _('Unattend') : _('Unfollow'))
  end

  def following_button(page, user)
    if !user.blank? and user != page.author
      if page.is_followed_by? user
        link_to unfollow_button_text(page), { controller: :profile,
                                              profile: page.profile.identifier,
                                              action: :unfollow_article,
                                              article_id: page.id },
                                              { title: "Unfollow" }
      else
        link_to follow_button_text(page), { controller: :profile,
                                            profile: page.profile.identifier,
                                            action: :follow_article,
                                            article_id: page.id },
                                            { title: "Follow" }
      end
    end
  end

  def filter_html(html, source)
    if @plugins && source && source.has_macro?
      html = convert_macro(html, source) unless @plugins.enabled_macros.blank?
      #TODO This parse should be done through the macro infra, but since there
      #     are old things that do not support it we are keeping this hot spot.
      html = @plugins.pipeline(:parse_content, html, source).first
    end
    html && html.html_safe
  end

  def article_to_html(article, options = {})
    options.merge!(:page => params[:npage])
    content = article.to_html(options)
    content = content.kind_of?(Proc) ? self.instance_eval(&content).html_safe : content.html_safe
    filter_html(content, article)
  end

  # Receives a list of type names. The names should be previously translated
  def custom_fields_for_article(types)
    types.map { |type| [type.camelize, type.downcase] }
  end

  def article_actions
    actions = [following_button(@page, user)]

    if @page.allow_edit?(user) && !remove_content_button(:edit, @page)
      content = font_awesome(:edit, label_for_edit_article(@page))
      url = profile.admin_url.merge({ controller: 'cms', action: 'edit', id: @page.id })
      actions << expirable_content_reference(@page, :edit, content, url)
    end

    if @page != profile.home_page && !@page.has_posts? && @page.allow_delete?(user) && !remove_content_button(:delete, @page)
      content = font_awesome('trash-o', _('Delete'))
      url = profile.admin_url.merge({ controller: 'cms', action: 'destroy', id: @page.id})
      options = { method: :post, 'data-confirm' => delete_article_message(@page) }
      actions << link_to(content, url, options)
    end

    if @page.allow_spread?(user) && !remove_content_button(:spread, @page)
      content = font_awesome(:spread, _('Spread'))
      url = profile.admin_url.merge({ controller: 'cms', action: 'publish', id: @page.id })
      actions << link_to(content, url, { modal: true} ) if url
    end

    if !@page.gallery? && (@page.allow_create?(user) || (@page.parent && @page.parent.allow_create?(user)))
      if @page.translatable? && !@page.native_translation.language.blank? && !remove_content_button(:locale, @page)
        content = font_awesome(:language, _('Add translation'))
        parent_id = (@page.folder? ? @page : (@page.parent.nil? ? nil : @page.parent))
        url = profile.admin_url.merge(controller: 'cms', action: 'new', parent_id: parent_id, type: @page.type, article: { translation_of_id: @page.native_translation.id })
        actions << link_to(content, url_for(url).html_safe)
      end

      if !@page.archived?
        actions << modal_link_to(font_awesome(:file, label_for_new_article(@page)), profile.admin_url.merge(controller: 'cms', action: 'new', parent_id: (@page.folder? ? @page : @page.parent))) unless remove_content_button(:new, @page)
      end

      content = font_awesome(:clone, label_for_clone_article(@page))
      url = profile.admin_url.merge({ controller: 'cms', action: 'new', id: @page.id, clone: true, parent_id: (@page.folder? ? @page : @page.parent), type: @page.class})
      actions << expirable_content_reference(@page, :clone, content, url)
    end

    if @page.accept_uploads? && @page.allow_create?(user)
      actions << link_to(font_awesome(:upload, _('Upload files')), profile.admin_url.merge(:controller => 'cms', :action => 'upload_files', :parent_id => (@page.folder? ? @page : @page.parent))) unless remove_content_button(:upload, @page)
    end

    if !@page.allow_create?(user) && profile.organization? && (@page.blog? || @page.parent && @page.parent.blog?) && !remove_content_button(:suggest, @page)
      content = font_awesome(:lightbulb, _('Suggest an article'))
      url = profile.admin_url.merge({ controller: 'cms', action: 'suggest_an_article' })
      options = { id: 'suggest-article-link' }
      actions << link_to(content, url, options)
    end

    if @page.display_versions?
      actions << link_to(font_awesome(:clock, _('All versions')), { controller: 'content_viewer', profile: profile.identifier, action: 'article_versions' }, id: 'article-versions-link')
    end

    plugins_toolbar_actions_for_article(@page).each do |plugin_button|
      plugin_button[:html_options] ||= {}
      plugin_button[:html_options][:title] ||= plugin_button[:title]
      title = font_awesome(plugin_button[:icon], plugin_button[:title])
      actions << link_to(title, plugin_button[:url], plugin_button[:html_options])
    end

    actions << fullscreen_buttons("#article") << report_abuse(profile, :link, @page)
  end

  def article_icon article
    if article.is_a? Folder
      image_tag "/designs/icons/tango/Tango/32x32/places/folder.png"
    elsif article.is_a? TextArticle
      image_tag "/designs/icons/tango/Tango/32x32/mimetypes/x-office-document.png"
    end
  end

end
