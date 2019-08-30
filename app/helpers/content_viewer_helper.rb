module ContentViewerHelper
  include BlogHelper
  include ForumHelper
  include DatesHelper

  def display_number_of_comments(n)
    base_str = "<span class='comment-count hide'>#{n}</span>"
    amount_str = n == 0 ? _("no comments yet") : (n == 1 ? _("One comment") : _("%s comments") % n)
    base_str += "<span class='comment-count-write-out'>#{font_awesome :comments} #{amount_str}</span>"
    base_str.html_safe
  end

  def number_of_comments(article)
    display_number_of_comments(article.comments_count - article.spam_comments_count.to_i)
  end

  def article_title(article, args = {})
    title = article.title
    title = content_tag("h1", h(title), class: "title")
    if article.belongs_to_blog? || article.belongs_to_forum?
      unless args[:no_link]
        title = content_tag("h1", link_to(article.title, url_for(article.view_url)), class: "title")
      end
      comments = ""
      unless args[:no_comments] || !article.accept_comments
        comments = (" - %s").html_safe % link_to_comments(article)
      end
      date_format = show_with_right_format_date article
      title << (render partial: "content_viewer/publishing_info", locals: { no_action_bar: true, article: article })
      title << content_tag(:div,
                           content_tag(:span, "", class: "ui-icon ui-icon-locked") +
                           content_tag(:span, _("This is a private content"), class: "alert-message"),
                           class: "private alert-text") if article.access.eql? Entitlement::Levels.levels[:self]
    end
    title
  end

  def show_with_right_format_date(article)
    date_format = article.environment.date_format
    use_numbers = false
    year = true
    left_time = false
    if date_format == "numbers_with_year"
      use_numbers = true
    elsif date_format == "numbers"
      use_numbers = true
      year = false
    elsif date_format == "month_name"
      year = false
    elsif date_format == "past_time"
      left_time = true
    end
    content_tag("span", show_time(article.published_at, use_numbers, year, left_time), class: "date")
  end

  def link_to_comments(article, args = {})
    return "" unless article.accept_comments?

    reference_to_article number_of_comments(article), article, "comments_list"
  end

  # FIXME
  # In application_helper.rb (line 706, col 107) if you change `reference_to_article`
  # to `link_to`, the article_block's start breaking.
  def reference_to_article(text, article, anchor = nil)
    if article.profile.domains.empty?
      href = "#{Noosfero.root}/#{article.url[:profile]}/"
    else
      href = "http://#{article.profile.domains.first.name}#{Noosfero.root}/"
    end
    href += article.url[:page].join("/")
    href += "#" + anchor if anchor
    content_tag("a", text, href: href)
  end

  def article_translations(article)
    unless article.native_translation.translations.empty?
      links = (article.native_translation.translations + [article.native_translation]).map do |translation|
        { article.environment.locales[translation.language] => { href: url_for(translation.url) } }
      end
      content_tag(:div, link_to(_("Translations"), "#",
                                onmouseover: "toggleSubmenu(this, '#{_('Translations')}', #{links.to_json}); return false",
                                class: "article-translations-menu simplemenu-trigger up"),
                  class: "article-translations")
    end
  end

  def addthis_image_tag
    if File.exists?(Rails.root.join("public", theme_path, "images", "addthis.gif"))
      image_tag(File.join(theme_path, "images", "addthis.gif"), border: 0, alt: "")
    else
      image_tag("/images/bt-bookmark.gif", width: 53, height: 16, border: 0, alt: "")
    end
  end
end
