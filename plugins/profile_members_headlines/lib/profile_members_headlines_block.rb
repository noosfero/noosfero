class ProfileMembersHeadlinesBlock < Block

  settings_items :interval, :type => 'integer', :default => 10
  settings_items :limit, :type => 'integer', :default => 10
  settings_items :navigation, :type => 'boolean', :default => true
  settings_items :filtered_roles, :type => Array, :default => []

  attr_accessible :interval, :limit, :navigation, :filtered_roles

  def self.description
    _('Display headlines from members of a community')
  end

  def help
    _('This block displays one post from members of a community.')
  end

  include Noosfero::Plugin::HotSpot

  def default_title
    _('Profile members headlines')
  end

  def filtered_roles=(array)
    self.settings[:filtered_roles] = array.map(&:to_i).select { |r| !r.to_i.zero? }
  end

  def authors_list
    result = owner.members_by_role(filtered_roles).is_public.includes([:image,:domains,:preferred_domain,:environment]).order('updated_at DESC')

    result.all(:limit => limit * 5).select { |p| p.has_headline?
}.slice(0..limit-1)
  end

  def content(args={})
    block = self
    members = authors_list
    proc do
      render :file => 'blocks/headlines', :locals => { :block => block, :members => members }
    end
  end

end
