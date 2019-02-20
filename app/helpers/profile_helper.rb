module ProfileHelper

  COMMON_CATEGORIES = {}
  COMMON_CATEGORIES[:content] = [:blogs, :image_galleries, :events, :article_tags]
  COMMON_CATEGORIES[:interests] = [:interests]
  COMMON_CATEGORIES[:general] = nil

  PERSON_CATEGORIES = {}
  PERSON_CATEGORIES[:basic_information] = {
          :nickname => {:name => 'nickname', :editable => true, :field => 'text' },
          :sex => {:name => 'sex', :editable => false},
          :birth_date => {:name => 'birth_date', :editable => false},
          :location => {:name => 'location', :editable => false },
          :privacy_setting => {:name => 'privacy_setting', :editable => false },
          :created_at => {:name => 'created_at', :editable => false }}

  PERSON_CATEGORIES[:contact] = {
          :contact_phone => {:name => 'contact_phone', :editable => true, :field => 'text' },
          :cell_phone => {:name => 'cell_phone', :editable => true, :field => 'text' },
          :comercial_phone => {:name => 'commercial_phone', :editable => true, :field => 'text' },
          :contact_information => {:name => 'contact_information', :editable => true, :field => 'text' },
          :email => {:name => 'email', :editable => true, :field => 'text' },
          :personal_website => {:name => 'personal_website', :editable => true, :field => 'text' },
          :jabber_id => {:name => 'jabber_id', :editable => true, :field => 'text' }}

  PERSON_CATEGORIES[:location] = {
          :address => {:name => 'address', :editable => false },
          :address_reference => {:name => 'address_reference', :editable => false },
          :zip_code => {:name => 'zip_code', :editable => false },
          :city => {:name => 'city', :editable => false },
          :state => {:name => 'state', :editable => false },
          :district => {:name => 'district', :editable => false },
          :country => {:name => 'country', :editable => false },
          :nationality => {:name => 'nationality', :editable => true, :field => 'text' }}

  PERSON_CATEGORIES[:work] = {
          :organization => {:name => 'organization', :editable => true, :field => 'text' },
          :organization_website => {:name => 'organization_website', :editable => true, :field => 'text' },
          :professional_activity => {:name => 'professional_activity', :editable => true, :field => 'text' }}

  PERSON_CATEGORIES[:study] = {
          :schooling =>    {:name => 'schooling', :editable => false },
          :formation =>    {:name => 'formation', :editable => false },
          :area_of_study=> {:name => 'area_of_study', :editable => false }}

  PERSON_CATEGORIES[:network] = [:friends, :followers, :followed_profiles, :communities, :enterprises]
  PERSON_CATEGORIES.merge!(COMMON_CATEGORIES)

  ORGANIZATION_CATEGORIES = {}
  ORGANIZATION_CATEGORIES[:basic_information] = [ :display_name,
                                                  :created_at,
                                                  :foundation_year,
                                                  :type, :language,
                                                  :members_count,
                                                  :location,
                                                  :address_reference,
                                                  :historic_and_current_context,
                                                  :admins ]

  ORGANIZATION_CATEGORIES[:contact] = {
          :contact_person => {:name => 'contact_person', :editable => true, :field => 'text' },
          :contact_phone => {:name => 'contact_phone', :editable => true, :field => 'text' },
          :contact_email => {:name => 'contact_email', :editable => true, :field => 'text' },
          :organization_website => {:name => 'organization_website', :editable => true, :field => 'text' },
          :jabber_id => {:name => 'jabber_id', :editable => false }}

  ORGANIZATION_CATEGORIES[:economic] = [:business_name,
                                        :acronym,
                                        :economic_activity,
                                        :legal_form,
                                        :activities_short_description,
                                        :management_information]

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

  def custom_labels
    {
      :zip_code => _('ZIP code'),
      :email => _('e-Mail'),
      :jabber_id => _('Jabber'),
      :birth_date => _('Date of birth'),
      :created_at => _('Profile created at'),
      :members_count => _('Members'),
      :privacy_setting => _('Privacy setting'),
      :article_tags => _('Tags'),
      :followed_profiles => _('Following'),
      :basic_information => _('Basic information'),
      :contact => _('Contact')
    }
  end

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
    custom_labels[field.to_sym] || _(field.to_s.humanize)
  end

  def display_field(field, editable=false, type=nil)
    force = FORCE[kind].include?(field)
    multiple = MULTIPLE[kind].include?(field)

    unless force || profile.may_display_field_to?(field, user)
      return ''
    end
    value = begin profile.send(field) rescue nil end

    return '' if value.blank?
    if value.kind_of?(Hash)
      content = self.send("treat_#{field}", value)
      content_tag('tr', content_tag('td', title(field), :class => 'field-name') +
                  content_tag('td', content))
    else
      entries = multiple ? value : [] << value
      entries.map do |entry|
        content = self.send("treat_#{field}", entry)
        if user.present? && user.has_permission?('edit_profile', profile) &&
            editable && type.present?
          content = render :partial => 'profile_editor/edit_in_place_field',
                           locals: { content: value, field: field, type: type }
        end
        unless content.blank?
          content_tag('tr', content_tag('td', title(field, entry), :class => 'field-name') +
                      content_tag('td', content.to_s.html_safe))
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

  def treat_admins(admins)
    profile.admins.map { |admin| link_to(admin.short_name, page_path(admin.identifier))}.join(', ')
  end

  def treat_blogs(blog)
    link_to(n_('One post', '%{num} posts', blog.posts.published.count) % { :num => blog.posts.published.count }, page_path(blog.profile.identifier, page: blog.page_path))
  end

  def treat_image_galleries(gallery)
    link_to(n_('One picture', '%{num} pictures', gallery.images.published.count) % { :num => gallery.images.published.count }, page_path(gallery.profile.identifier, page: gallery.page_path))
  end

  def treat_followers(followers)
    link_to(profile.followers.count, {:action=>"followed", :controller=>"profile", :profile=>"#{profile.identifier}"})
  end

  def treat_followed_profiles(followed_profiles)
    link_to(profile.followed_profiles.count, {:action=>"following", :controller=>"profile", :profile=>"#{profile.identifier}"})
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
    article.title
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

      if fields.kind_of?(Hash)
        fields.each do |key, field|
            contents << display_field(field[:name], field[:editable], field[:field]).html_safe
        end
      else
        fields.each do |field|
            contents << display_field(field).html_safe
        end
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
