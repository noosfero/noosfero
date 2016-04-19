module ArticleHelper

  include TokenHelper

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
      ) : '')
    )
  end

  def visibility_options(article, tokenized_children)
    content_tag('h4', _('Visibility')) +
    content_tag('div',
      content_tag('div',
        radio_button(:article, :published, true) +
          content_tag('span', '&nbsp;', :class => 'access-public-icon') +
          content_tag('label', _('Public'), :for => 'article_published_true') +
          content_tag('span', _('Visible to other people'), :class => 'access-note'),
          :class => 'access-item'
           ) +
      content_tag('div',
        radio_button(:article, :published, false) +
          content_tag('span', '&nbsp;', :class => 'access-private-icon') +
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

    general_options = Forum::TopicCreation.general_options(article)
    slider_options = {:id => 'topic-creation-slider'}
    slider_options = general_options.keys.inject(slider_options) do |result, option|
      result.merge!({'data-'+option => general_options[option]})
    end

    content_tag('h4', _('Topic creation')) +
    content_tag( 'small', _('Who will be able to create new topics on this forum?')) +
    content_tag('div', '', slider_options) +
    hidden_field_tag('article[topic_creation]', article.topic_creation) +
    javascript_include_tag("#{Noosfero.root}/assets/topic-creation-config.js")
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

  def cms_label_for_new_children
    _('New article')
  end

  def cms_label_for_edit
    _('Edit')
  end

  def follow_button_text(article)
    if article.event?
      _('Attend')
    else
      _('Follow')
    end
  end

  def unfollow_button_text(article)
    if article.event?
      _('Unattend')
    else
      _('Unfollow')
    end
  end

  def following_button(page, user)
    if !user.blank? and user != page.author
      if page.is_followed_by? user
        button :cancel, unfollow_button_text(page), {:controller => 'profile', :action => 'unfollow_article', :article_id => page.id, :profile => page.profile.identifier}
      else
        button :add, follow_button_text(page), {:controller => 'profile', :action => 'follow_article', :article_id => page.id, :profile => page.profile.identifier}
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
    content = content.kind_of?(Proc) ? self.instance_exec(&content).html_safe : content.html_safe
    filter_html(content, article)
  end

end
