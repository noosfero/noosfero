module ProfileHelper

  COMMON_CATEGORIES = {}
  COMMON_CATEGORIES[:content] = [:blogs, :image_galleries, :events, :article_tags]
  COMMON_CATEGORIES[:interests] = [:interests]
  COMMON_CATEGORIES[:general] = nil

  PERSON_CATEGORIES = {}
  PERSON_CATEGORIES[:basic_information] = [:nickname, :sex, :birth_date, :location, :privacy_setting, :created_at]
  PERSON_CATEGORIES[:contact] = [:contact_phone, :cell_phone, :comercial_phone, :contact_information, :email, :personal_website, :jabber_id]
  PERSON_CATEGORIES[:location] = [:address, :address_reference, :zip_code, :city, :state, :district, :country, :nationality]
  PERSON_CATEGORIES[:work] = [:organization, :organization_website, :professional_activity]
  PERSON_CATEGORIES[:study] = [:schooling, :formation, :area_of_study]
  PERSON_CATEGORIES[:network] = [:friends, :communities, :enterprises]
  PERSON_CATEGORIES.merge!(COMMON_CATEGORIES)

  ORGANIZATION_CATEGORIES = {}
  ORGANIZATION_CATEGORIES[:basic_information] = [:display_name, :created_at, :foundation_year, :type, :language, :members_count, :location, :address_reference, :historic_and_current_context, :admins]
  ORGANIZATION_CATEGORIES[:contact] = [:contact_person, :contact_phone, :contact_email, :organization_website, :jabber_id]
  ORGANIZATION_CATEGORIES[:economic] = [:business_name, :acronym, :economic_activity, :legal_form, :products, :activities_short_description, :management_information]
  ORGANIZATION_CATEGORIES.merge!(COMMON_CATEGORIES)

  CATEGORY_MAP = {}
  CATEGORY_MAP[:person] = PERSON_CATEGORIES
  CATEGORY_MAP[:organization] = ORGANIZATION_CATEGORIES

  FORCE = {
    :person => [:privacy_setting],
    :organization => [:privacy_setting, :location],
  }

  MULTIPLE = {
    :person => [:blogs, :image_galleries, :interests],
    :organization => [:blogs, :image_galleries, :interests],
  }

  CUSTOM_LABELS = {
    :zip_code => _('ZIP code'),
    :email => _('e-Mail'),
    :jabber_id => _('Jabber'),
    :birth_date => _('Date of birth'),
    :created_at => _('Profile created at'),
    :members_count => _('Members'),
    :privacy_setting => _('Privacy setting'),
    :article_tags => _('Tags')
  }

  EXCEPTION = {
    :person => [:image, :preferred_domain, :description, :tag_list],
    :organization => [:image, :preferred_domain, :description, :tag_list, :address, :zip_code, :city, :state, :country, :district]
  }

  def general_fields
    categorized_fields = CATEGORY_MAP[kind].values.flatten
    profile.class.fields.map(&:to_sym) - categorized_fields - EXCEPTION[kind]
  end

  def kind
    if profile.kind_of?(Person)
      :person
    else
      :organization
    end
  end

  def title(field, entry = nil)
    return self.send("#{field}_custom_title", entry) if MULTIPLE[kind].include?(field) && entry.present?
    CUSTOM_LABELS[field.to_sym] || _(field.to_s.humanize)
  end

  def display_field(field)
    force = FORCE[kind].include?(field)
    multiple = MULTIPLE[kind].include?(field)
    unless force || profile.may_display_field_to?(field, user)
      return ''
    end
    value = begin profile.send(field) rescue nil end
    return '' if value.blank?
    if value.kind_of?(Hash)
      content = self.send("treat_#{field}", value)
      content_tag('tr', content_tag('td', title(field), :class => 'field-name') + content_tag('td', content))
    else
      entries = multiple ? value : [] << value
      entries.map do |entry|
        content = self.send("treat_#{field}", entry)
        unless content.blank?
          content_tag('tr', content_tag('td', title(field, entry), :class => 'field-name') + content_tag('td', content))
        end
      end.join("\n")
    end
  end

  def treat_email(email)
    link_to_email(email)
  end

  def treat_organization_website(url)
    link_to(url, url)
  end

  def treat_sex(gender)
    { 'male' => _('Male'), 'female' => _('Female') }[gender]
  end

  def treat_date(date)
    show_date(date.to_date)
  end
  alias :treat_birth_date :treat_date
  alias :treat_created_at :treat_date

  def treat_friends(friends)
     link_to friends.count, :controller => 'profile', :action => 'friends'
  end

  def treat_communities(communities)
    link_to communities.count, :controller => "profile", :action => 'communities'
  end

  def treat_enterprises(enterprises)
    if environment.disabled?('disable_asset_enterprises')
      link_to enterprises.count, :controller => "profile", :action => 'enterprises'
    end
  end

  def treat_members_count(count)
    link_to count, :controller => 'profile', :action => 'members'
  end

  def treat_products(products)
    if profile.kind_of?(Enterprise) && profile.environment.enabled?('products_for_enterprises')
      link_to _('Products/Services'), :controller => 'catalog', :action => 'index'
    end
  end

  def treat_admins(admins)
    profile.admins.map { |admin| link_to(admin.short_name, admin.url)}.join(', ')
  end

  def treat_blogs(blog)
    link_to(n_('One post', '%{num} posts', blog.posts.published.count) % { :num => blog.posts.published.count }, blog.url)
  end

  def treat_image_galleries(gallery)
    link_to(n_('One picture', '%{num} pictures', gallery.images.published.count) % { :num => gallery.images.published.count }, gallery.url)
  end

  def treat_events(events)
    link_to events.published.count, :controller => 'events', :action => 'events'
  end

  def treat_article_tags(tags)
    tag_cloud @tags, :id, { :action => 'tags' }, :max_size => 18, :min_size => 10
  end

  def treat_interests(interest)
    link_to interest.name, :controller => 'search', :action => 'category_index', :category_path => interest.explode_path
  end

  def article_custom_title(article)
    article.name
  end
  alias :blogs_custom_title :article_custom_title
  alias :image_galleries_custom_title :article_custom_title

  def interests_custom_title(interest)
    ''
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^treat_(.+)$/
      args[0]
    elsif method.to_s =~ /^display_(.+)$/ && CATEGORY_MAP[kind].has_key?($1.to_sym)
      category = $1.to_sym
      fields = category == :general ? general_fields : CATEGORY_MAP[kind][category]
      contents = []

      fields.each do |field|
        contents << display_field(field).html_safe
      end

      contents = contents.delete_if(&:blank?)

      unless contents.empty?
        content_tag('tr', content_tag('th', title(category), { :colspan => 2 })) + contents.join.html_safe
      else
        ''
      end
    else
      super
    end
  end

end
