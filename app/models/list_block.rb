class ListBlock < Block

  def content
    Profile.find(:all).map{|p|p.name}
  end
end
