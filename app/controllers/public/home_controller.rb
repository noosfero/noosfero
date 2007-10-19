class HomeController < PublicController

  design :holder => 'environment'
  def index
    redirect_to homepage_path(:profile => 'noosfero') if Profile.find_by_identifier('noosfero')
  end
end
