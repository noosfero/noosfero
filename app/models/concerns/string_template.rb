module StringTemplate

  include SanitizeHelper

  def title
    parse_string_params(self, super)
  end

  def to_html(options = {})
    article, content = self, super
    if content.is_a? Proc
      -> context { article.parse_string_params(article, self.instance_exec(context, &content)) }
    else
      parse_string_params(article, content)
    end
  end

  def abstract
    parse_string_params(self, super)
  end

end
