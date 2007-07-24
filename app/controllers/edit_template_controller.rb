class EditTemplateController < ApplicationController

#  before_filter :leila
  uses_flexible_template :edit => true, :owner => 'owner'

#  def leila
#    @owner = Profile.find(1)
#  end

end
