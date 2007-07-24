class HomeController < ApplicationController

  def index
  end

  uses_flexible_template :edit => false, :owner => 'owner'

end
