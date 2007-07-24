class EditTemplateController < ApplicationController

  uses_flexible_template :edit => true

  def flexible_template_owner
    Profile.find(1)
  end

end
