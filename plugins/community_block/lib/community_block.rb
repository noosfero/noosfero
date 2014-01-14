class CommunityBlock < Block

  def self.description
    "Community block"
  end

  def help
    "Help for Community Description Block."
  end

  def content(arg={})
    block = self

    lambda do
      render :file => 'community_block', :locals => { :block => block }
    end
  end

end
