# Methods added to this helper will be available to all templates in the application.
module EditTemplateHelper
  def flexible_template_block_dict(str)
    {
      'MainBlock' => _("Main Block"),
      'ListBlock' => _("List Block"),
      'LinkBlock' => _("Link Block")
    }[str] || str
  end

end
