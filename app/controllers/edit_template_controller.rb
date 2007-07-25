class EditTemplateController < ApplicationController

  uses_flexible_template :edit => true, :owner => 'owner'

  def flexible_template_owner
    Profile.find(1)
  end

  def flexible_template_dict(str)
    {
      'MainBlock' => _("Main Block"),
      'ListBlock' => _("List Block"),
      'LinkBlock' => _("Link Block")
    }[str] || str
  end


end
