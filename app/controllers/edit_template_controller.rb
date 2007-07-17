class EditTemplateController < ApplicationController

  uses_manage_template :edit => true

  def test
    @bli = true
    render :action => 'index'
  end

end
