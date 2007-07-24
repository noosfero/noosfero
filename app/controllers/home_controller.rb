class HomeController < ApplicationController

  uses_flexible_template :owner => 'owner'

  def flexible_template_owner
    Profile.find(1)
  end

end
