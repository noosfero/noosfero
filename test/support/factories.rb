module Noosfero::Factory

  def fast_create(name, attrs = {}, options = {})
    defaults = defaults_for(name)
    attrs[:slug] = attrs[:name].to_slug if attrs[:name].present? && attrs[:slug].blank? && defaults[:slug].present?
    data = defaults_for(name.to_s.gsub('::','')).merge(attrs)
    klass = name.to_s.camelize.constantize
    if klass.superclass != ActiveRecord::Base
      data[:type] = klass.to_s
    end
    if options[:timestamps]
      fast_insert_with_timestamps(klass, data)
    else
      fast_insert(klass, data)
    end
    obj = klass.order(:id).last
    if options[:category]
      categories = options[:category]
      unless categories.is_a?(Array)
        categories = [categories]
      end
      categories.each do |category|
        obj.add_category(category)
      end
    end
    obj
  end

  def create(name, attrs = {})
    target = 'create_' + name.to_s
    if respond_to?(target)
      send(target, attrs)
    else
      obj = build name
      attrs.each{ |a, v| obj.send "#{a}=", v }
      obj.save!
      obj
    end
  end

  def build(name, attrs = {})
    defaults = defaults_for(name)
    attrs[:slug] = attrs[:name].to_slug if attrs[:name].present? && attrs[:slug].blank? && defaults[:slug].present?
    data = defaults_for(name).merge(attrs)
    object = name.to_s.camelize.constantize.new
    if object.respond_to?(:assign_attributes)
      object.assign_attributes(data, :without_protection => true)
    else
      data.each { |attribute, value| object.send(attribute.to_s+'=', value) }
    end
    object
 end

  def defaults_for(name)
    send('defaults_for_' + name.to_s.underscore)
  rescue
    {}
  end

  def self.num_seq
    @num_seq ||= 0
    @num_seq += 1
    @num_seq
  end

  ###### old stuff to be rearranged
  def create_admin_user(env)
    admin_user = User.find_by(login: 'adminuser') || create_user('adminuser', :email => 'adminuser@noosfero.org', :password => 'adminuser', :password_confirmation => 'adminuser', :environment => env)
    admin_role = Role.find_by(name: 'admin_role') || Role.create!(:name => 'admin_role', :permissions => ['view_environment_admin_panel','edit_environment_features', 'edit_environment_design', 'manage_environment_categories', 'manage_environment_roles', 'manage_environment_trusted_sites', 'manage_environment_validators', 'manage_environment_users', 'manage_environment_organizations', 'manage_environment_templates', 'manage_environment_licenses', 'edit_appearance'])
    create(RoleAssignment, :accessor => admin_user.person, :role => admin_role, :resource => env) unless admin_user.person.role_assignments.map{|ra|[ra.role, ra.accessor, ra.resource]}.include?([admin_role, admin_user, env])
    admin_user.login
  end

  def create_environment(domainname)
    environment = fast_create(Environment)
    fast_create(Domain, :name => domainname, :owner_type => 'Environment', :owner_id => environment.id)
    environment
  end

  # Old version of create user. Use it if you need to create an user for
  # testing that passes through the actual user creation process.
  #
  # Be aware that this is slow, though.
  def create_user_full(name = nil, options = {}, person_options = {})
    name ||= 'user' + factory_num_seq.to_s
    data = {
      :login => name,
      :email => name + '@noosfero.org',
      :password => name.underscore,
      :password_confirmation => name.underscore
    }.merge(options)
    user = build(User, data)
    user.person_data = person_options
    user.save!
    user
  end

  def person_data
    {}
  end

  # This method knows way too much about the model. But since creating an
  # actual user is really expensive, for tests we need a fast alternative.
  def create_user(name = nil, options = {}, person_options = {})
    name ||= 'user' + factory_num_seq.to_s
    environment_id = options.delete(:environment_id) || (options.delete(:environment) || Environment.default).id

    password = options.delete(:password)
    password_confirmation = options.delete(:password_confirmation)
    raise build(Exception, "Passwords don't match") if (password && password_confirmation && password != password_confirmation)
    crypted_password = (password || name).crypt('xy')

    data = {
      :login => name,
      :email => name + '@noosfero.org',
      :crypted_password => crypted_password,
      :password_type => 'crypt',
      :salt => 'xy',
      :environment_id => environment_id,
    }.merge(options)
    user = fast_insert_with_timestamps(User, data)
    person = fast_insert_with_timestamps(Person, { :type => 'Person', :identifier => name, :name => name, :user_id => user.id, :environment_id => environment_id }.merge(person_options))
    homepage = fast_insert_with_timestamps(TextileArticle, { :type => 'TextileArticle', :name => 'homepage', :slug => 'homepage', :path => 'homepage', :profile_id => person.id })
    fast_update(person, {:home_page_id => homepage.id})
    box = fast_insert(Box, { :owner_type => "Profile", :owner_id => person.id, :position => 1})
    block = fast_insert(Block, { :box_id => box.id, :type => 'MainBlock', :position => 0})
    user
  end

  def fast_insert(klass, data)
    names = data.keys
    values = names.map {|k| ActiveRecord::Base.send(:sanitize_sql_array, ['?', data[k]]) }
    sql = 'insert into %s(%s) values (%s)' % [klass.table_name, names.join(','), values.join(',')]
    klass.connection.execute(sql)
    klass.order(:id).last
  end

  def fast_insert_with_timestamps(klass, data)
    now = Time.now
    fast_insert(klass, { :created_at => now, :updated_at => now}.merge(data))
  end

  def fast_update(obj, data)
    obj.class.connection.execute('update %s set %s where id = %d' % [obj.class.table_name, obj.class.send(:sanitize_sql_for_assignment, data), obj.id])
  end

  def give_permission(user, permission, target)
    user = Person.find_by(identifier: user) if user.kind_of?(String)
    target ||= user
    i = 0
    while Role.find_by(name: 'test_role' + i.to_s)
      i+=1
    end

    role = create(Role, :name => 'test_role' + i.to_s, :permissions => [permission])
    assert user.add_role(role, target)
    assert user.has_permission?(permission, target)
    user
  end

  def create_user_with_permission(name, permission, target= nil)
    user = create_user(name).person
    give_permission(user, permission, target)
  end


  protected

  def factory_num_seq
    Noosfero::Factory.num_seq
  end

  ###############################################
  # Environment
  ###############################################

  def defaults_for_environment
    seq = factory_num_seq
    {
      :name => "Environment %d" % seq,
      :contact_email => "environment%d@example.com" % seq
    }
  end

  ###############################################
  # Enterprise
  ###############################################

  def defaults_for_enterprise
    n = factory_num_seq.to_s
    defaults_for_profile.merge({ :identifier => "enterprise-" + n, :name => 'Enterprise ' + n })
  end

  ###############################################
  # Community
  ###############################################

  def defaults_for_community
    n = factory_num_seq.to_s
    defaults_for_profile.merge({ :identifier => "community-" + n, :name => 'Community ' + n })
  end

  ###############################################
  # Person
  ###############################################

  def defaults_for_person
    n = factory_num_seq.to_s
    defaults_for_profile.merge({ :identifier => "person-" + n, :name => 'Person ' + n, :created_at => DateTime.now })
  end

  ###############################################
  # Profile
  ###############################################

  def defaults_for_profile
    n = factory_num_seq.to_s
    { :public_profile => true, :identifier => 'profile-' + n, :name => 'Profile ' + n, :environment_id => 1 }
  end

  ###############################################
  # Organization
  ###############################################

  def defaults_for_organization
    n = factory_num_seq.to_s
    defaults_for_profile.merge({:identifier => 'organization-' + n, :name => 'Organization ' + n})
  end

  ###############################################
  # Article (and friends)
  ###############################################

  def defaults_for_article
    name = 'My article ' + factory_num_seq.to_s
    { :name => name, :slug => name.to_slug, :path => name.to_slug }
  end

  alias :defaults_for_text_article       :defaults_for_article
  alias :defaults_for_textile_article    :defaults_for_article
  alias :defaults_for_tiny_mce_article   :defaults_for_article
  alias :defaults_for_rss_feed           :defaults_for_article
  alias :defaults_for_published_article  :defaults_for_article
  alias :defaults_for_folder             :defaults_for_article

  ###############################################
  # Event
  ###############################################

  def defaults_for_event
    num = factory_num_seq.to_s
    {
      :name => 'My event ' + num,
      :slug => 'my-event-' + num,
      :path => '/my-event-' + num,
      :start_date => Date.today
    }
  end

  ###############################################
  # UploadedFile
  ###############################################

  def defaults_for_uploaded_file
    name = 'My uploaded file ' + factory_num_seq.to_s
    { :name => name, :abstract => name }
  end

  ###############################################
  # Blog
  ###############################################
  def defaults_for_blog
    name = 'My blog ' + factory_num_seq.to_s
    { :name => name, :slug => name.to_slug, :path => name.to_slug }
  end

  def create_blog
    profile = create(Profile, :identifier => 'testuser' + factory_num_seq.to_s, :name => 'Test user')
    create(Blog, :name => 'blog', :profile => profile)
  end

  ###############################################
  # ExternalFeed
  ###############################################
  def defaults_for_external_feed
    { :address => Rails.root.join('test', 'fixtures', 'files', 'feed.xml'), :blog_id => factory_num_seq }
  end

  def create_external_feed(attrs = {})
    feed = build(:external_feed, attrs)
    feed.blog = create_blog
    feed.save!
    feed
  end

  ###############################################
  # FeedReaderBlock
  ###############################################
  def defaults_for_feed_reader_block
    { :address => Rails.root.join('test/fixtures/files/feed.xml') }
  end

  ###############################################
  # Domain
  ###############################################
  def defaults_for_domain
    { :name => 'example' + factory_num_seq.to_s + '.com' }
  end

  ###############################################
  # Category
  ###############################################
  def defaults_for_category
    name = 'category' + factory_num_seq.to_s
    { :environment_id => 1, :name => name, :slug => name.to_slug, :path => name.to_slug }
  end

  alias :defaults_for_region :defaults_for_category
  alias :defaults_for_product_category :defaults_for_category

  ###############################################
  # Box
  ###############################################
  def defaults_for_box
    { }
  end

  ###############################################
  # Block
  ###############################################
  def defaults_for_block
    { }
  end

  alias :defaults_for_blog_archives_block :defaults_for_block
  alias :defaults_for_profile_list_block :defaults_for_block

  ###############################################
  # Task
  ###############################################
  def defaults_for_task
    { :code => "task_for_test_#{factory_num_seq.to_s}" }
  end

  alias :defaults_for_add_friend :defaults_for_task
  alias :defaults_for_add_member :defaults_for_task
  alias :defaults_for_create_community :defaults_for_task
  alias :defaults_for_email_activation :defaults_for_task

  ###############################################
  # Product
  ###############################################

  def defaults_for_product
    { :name => 'Product ' + factory_num_seq.to_s }
  end

  ###############################################
  # Input
  ###############################################

  def defaults_for_input
    { }
  end

  ###############################################
  # Contact
  ###############################################

  def defaults_for_contact
    { :subject => 'hello there', :message => 'here I come to SPAM you' }
  end

  ###############################################
  # Qualifier
  ###############################################

  def defaults_for_qualifier
    { :name => 'Qualifier ' + factory_num_seq.to_s, :environment_id => 1 }
  end

  ###############################################
  # Certifier
  ###############################################

  def defaults_for_certifier
    defaults_for_qualifier.merge({ :name => 'Certifier ' + factory_num_seq.to_s })
  end

  ###############################################
  # Scrap
  ###############################################

  def defaults_for_scrap(params = {})
    { :content => 'some content ', :sender_id => 1, :receiver_id => 1, :created_at => DateTime.now }.merge(params)
  end

  ###############################################
  # ActionTrackerNotification
  ###############################################

  def defaults_for_action_tracker_notification(params = {})
    { :action_tracker_id => 1, :profile_id => 1 }.merge(params)
  end

  ###############################################
  # ActionTracker
  ###############################################

  def defaults_for_action_tracker_record(params = {})
    { :created_at => DateTime.now, :verb => 'add_member_in_community', :user_type => 'Profile', :user_id => 1 }.merge(params)
  end

  ###############################################
  # Friendship
  ###############################################

  def defaults_for_friendship(params = {})
    { :created_at => DateTime.now, :person_id => 1, :friend_id => 2 }.merge(params)
  end

  ###############################################
  # RoleAssignment
  ###############################################

  def defaults_for_role_assignment(params = {})
    { :role_id => 1, :accessor_id => 1, :accessor_type => 'Profile', :resource_id => 2, :resource_type => 'Profile' }.merge(params)
  end

  ###############################################
  # User
  ###############################################

  def defaults_for_user(params = {})
    username = "user_#{rand(1000)}"
    { :login => username, :email => username + '@noosfero.colivre', :crypted_password => 'test'}.merge(params)
  end

  ###############################################
  # Forum
  ###############################################

  def defaults_for_forum(params = {})
    name = "forum_#{rand(1000)}"
    { :profile_id => 1, :path => name.to_slug, :name => name, :slug => name.to_slug }.merge(params)
  end

  ###############################################
  # Gallery
  ###############################################

  def defaults_for_gallery(params = {})
    name = "gallery_#{rand(1000)}"
    { :profile_id => 1, :path => name.to_slug, :name => name, :slug => name.to_slug }.merge(params)
  end

  def defaults_for_suggest_article
    { :name => 'Sender', :email => 'sender@example.com', :article => {:name => 'Some title', :body => 'some body text', :abstract => 'some abstract text'}}
  end

  def defaults_for_comment(params = {})
    name = "comment_#{rand(1000)}"
    { :title => name, :body => "my own comment", :source_id => 1, :source_type => 'Article' }.merge(params)
  end

  ###############################################
  # Unit
  ###############################################

  def defaults_for_unit
    { :singular => 'Litre', :plural => 'Litres', :environment_id => 1 }
  end

  ###############################################
  # Production Cost
  ###############################################

  def defaults_for_production_cost
    { :name => 'Production cost ' + factory_num_seq.to_s }
  end

  ###############################################
  # National Region
  ###############################################

  def defaults_for_national_region
    { :name => 'National region ' + factory_num_seq.to_s }
  end

  def defaults_for_license
    name = "License #{rand(1000)}"
    slug = name.to_slug
    { :name => name, :url => "#{slug}.org", :slug => slug, :environment_id => 1}
  end

end
