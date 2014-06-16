class CommunityBlock < Block

  def self.description
    _("Community block")
  end

  def help
    _("Help for Community Description Block.")
  end

  def content(arg={})
    block = self

    proc do
      render :file => 'community_block', :locals => { :block => block }
    end
  end

end
