class StatisticsBlock < Block

  settings_items :community_counter, :default => false
  settings_items :user_counter, :default => true
  settings_items :enterprise_counter, :default => false
  settings_items :product_counter, :default => false
  settings_items :category_counter, :default => false
  settings_items :tag_counter, :default => true
  settings_items :comment_counter, :default => true
  settings_items :hit_counter, :default => false
  settings_items :templates_ids_counter, Hash, :default => {}

  attr_accessible :comment_counter, :community_counter, :user_counter, :enterprise_counter, :product_counter, :category_counter, :tag_counter, :hit_counter, :templates_ids_counter

  USER_COUNTERS = [:community_counter, :user_counter, :enterprise_counter, :tag_counter, :comment_counter, :hit_counter]
  COMMUNITY_COUNTERS = [:user_counter, :tag_counter, :comment_counter, :hit_counter]
  ENTERPRISE_COUNTERS = [:user_counter, :tag_counter, :comment_counter, :hit_counter]

  def self.description
    c_('Statistics')
  end

  def default_title
    _('Statistics for %s') % owner.name
  end

  def is_visible? counter
    value = self.send(counter)
    value == '1' || value == true
  end

  def is_counter_available? counter
    if owner.kind_of?(Environment)
      true
    elsif owner.kind_of?(Person)
      USER_COUNTERS.include?(counter)
    elsif owner.kind_of?(Community)
      COMMUNITY_COUNTERS.include?(counter)
    elsif owner.kind_of?(Enterprise)
      ENTERPRISE_COUNTERS.include?(counter)
    end

  end

  def help
    _('This block presents some statistics about your context.')
  end

  def timeout
    60.minutes
  end

  def environment
    if owner.kind_of?(Environment)
      owner
    elsif owner.kind_of?(Profile)
      owner.environment
    else
      nil
    end
  end

  def templates
    Community.templates(environment)
  end

  def is_template_counter_active? template_id
    self.templates_ids_counter[template_id.to_s].to_s == 'true'
  end

  def template_counter_count(template_id)
    owner.communities.visible.count(:conditions => {:template_id => template_id})
  end

  def users
    if owner.kind_of?(Environment)
      owner.people.visible.count
    elsif owner.kind_of?(Organization)
      owner.members.visible.count
    elsif owner.kind_of?(Person)
      owner.friends.visible.count
    else
      0
    end
  end

  def enterprises
    if owner.kind_of?(Environment) || owner.kind_of?(Person)
      owner.enterprises.visible.enabled.count
    else
      0
    end
  end

  def products
    if owner.kind_of?(Environment)
      owner.products.where("profiles.enabled = true and profiles.visible = true").count
    elsif owner.kind_of?(Enterprise)
      owner.products.count
    else
      0
    end
  end

  def communities
    if owner.kind_of?(Environment) || owner.kind_of?(Person)
      owner.communities.visible.count
    else
      0
    end
  end

  def categories
    if owner.kind_of?(Environment) then
      owner.categories.count
    else
      0
    end
  end

  def tags
    if owner.kind_of?(Environment) then
      owner.tag_counts.count
    elsif owner.kind_of?(Profile) then
      owner.article_tags.count
    else
      0
    end
  end

  def comments
    if owner.kind_of?(Environment) then
      owner.profiles.joins(:articles).sum(:comments_count).to_i
    elsif owner.kind_of?(Profile) then
      owner.articles.sum(:comments_count)
    else
      0
    end
  end

  def hits
    if owner.kind_of?(Environment) then
      owner.profiles.joins(:articles).sum(:hits).to_i
    elsif owner.kind_of?(Profile) then
      owner.articles.sum(:hits)
    else
      0
    end
  end

  def content(args={})
    block = self

    proc do
      render :file => 'statistics_block', :locals => { :block => block }
    end
  end

end
