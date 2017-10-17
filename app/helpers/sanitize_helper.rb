module SanitizeHelper

  #STRING_PARAMS_REGEX = /!([^\s|$|!]+)/
  STRING_PARAMS_REGEX = /!([\w|-]+)/
  STRING_DEFAULT_PARAMS = {
    'id' => {
      description: _('The id of the %s'),
      value: -> (obj) { obj.id }
    }
  }

  def sanitize_html(text, type= :full_sanitize)
    sanitizer(type).sanitize(text, scrubber: permit_scrubber)
  end
  def sanitize_link(text)
    sanitizer(:white_list).sanitize(text, tags: allowed_tags, attributes: allowed_attributes)
  end

  def string_params_for(klass)
    begin
      params = send("#{klass.name.underscore}_string_params")
      STRING_DEFAULT_PARAMS.merge(params)
    rescue NoMethodError
      STRING_DEFAULT_PARAMS
    end
  end

  def parse_string_params(obj, content)
    return content unless content.is_a? String

    params = string_params_for(obj.class.base_class)
    content.gsub STRING_PARAMS_REGEX do |param|
      f = params[param[1..-1]]
      f ? f[:value].call(obj) : param
    end
  end

protected

  def allowed_tags
    Rails.application.config.action_view.sanitized_allowed_tags
  end

  def allowed_attributes
    Rails.application.config.action_view.sanitized_allowed_attributes
  end

  def permit_scrubber
    scrubber = Rails::Html::PermitScrubber.new
    scrubber.tags = Rails.application.config.action_view.sanitized_allowed_tags
    scrubber.attributes = Rails.application.config.action_view.sanitized_allowed_attributes
    scrubber
  end

  def sanitizer type = :full_sanitize
    return HTML::WhiteListSanitizer.new if type == :white_list
    HTML::FullSanitizer.new
  end

  def article_string_params
    {
      'article_name' => {
        description: _('Title of the article'),
        value: -> (article) { article.name }
      },
      'profile_name' => {
        description: _("Name of article's profile"),
        value: -> (article) { article.profile.name }
      },
      'profile_identifier' => {
        description: _("Identifier of article's profile"),
        value: -> (article) { article.profile.identifier }
      },
      'author_identifier' => {
        description: _("Identifier of article's author"),
        value: -> (article) { article.author.identifier }
      },
      'author_name' => {
        description: _("Name of article's author"),
        value: -> (article) { article.author.name }
      },
      'author_email' => {
        description: _("Email of article's author"),
        value: -> (article) { article.author.email }
      }
    }
  end

  def block_string_params
    {
      'identifier' => {
        description: _("Identifier of the block's profile"),
        value: -> (block) { block.owner.try(:identifier) ? block.owner.identifier : block.owner.name.to_slug}
      },
      'profile_name' => {
        description: _("Name of the block's profile"),
        value: -> (block) { block.owner.name }
      },
      'profile_email' => {
        description: _("Email of the block's profile"),
        value: -> (block) { block.owner.try(:email) ? block.owner.email : block.owner.try(:contact_email)}
      },
      'title' => {
        description: _('Title of the block'),
        value: -> (block) { block.title }
      }
    }
  end
end
