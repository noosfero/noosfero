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
    content_tag('h4', _('Options')) +
    content_tag('div',
      (article.profile.has_members? ?
      content_tag(
        'div',
        check_box(:article, :allow_members_to_edit) +
        content_tag('label', _('Allow all members to edit this article'), :for => 'article_allow_members_to_edit')
      ) :
      '') +

      (article.parent && article.parent.forum? && controller.action_name == 'new' ?
      hidden_field_tag('article[accept_comments]', 1) :
      content_tag(
        'div',
        check_box(:article, :accept_comments) +
        content_tag('label', (article.parent && article.parent.forum? ? _('This topic is opened for replies') : _('I want to receive comments about this article')), :for => 'article_accept_comments')
      )) +

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

      (article.forum? && article.profile.community? ?
      content_tag(
        'div',
        check_box(:article, :allows_members_to_create_topics) +
        content_tag('label', _('Allow members to create topics'), :for => 'article_allows_members_to_create_topics')
        ) : '')
    )
  end

  def visibility_options(article, tokenized_children)
    content_tag('h4', _('Visibility')) +
    content_tag('div',
      content_tag('div',
        radio_button(:article, :published, true) +
          content_tag('label', _('Public (visible to other people)'), :for => 'article_published_true')
           ) +
      content_tag('div',
        radio_button(:article, :published, false) +
          content_tag('label', _('Private'), :for => 'article_published_false', :id => "label_private")
      ) +
      privacity_exceptions(article, tokenized_children)
    )
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
    label_message = article.profile.organization? ? _('For all community members') : _('For all your friends')

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
          _('Fill in the search field to add the exception users to see this content'),
          :id => "text-input-search-exception-users"
        ) +
        token_input_field_tag(
          :q,
          'search-article-privacy-exceptions',
          {:action => 'search_article_privacy_exceptions'},
          {
            :focus => false,
            :hint_text => _('Type in a search term for a user'),
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

end
