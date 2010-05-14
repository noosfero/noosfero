module Noosfero::Factory

  def fast_create(name, attrs = {}, options = {})
    data = defaults_for(name).merge(attrs)
    klass = name.to_s.camelize.constantize
    if klass.superclass != ActiveRecord::Base
      data[:type] = klass.to_s
    end
    if options[:timestamps]
      fast_insert_with_timestamps(klass, data)
    else
      fast_insert(klass, data)
    end
    obj = klass.last(:order => "id")
    if options[:category]
      categories = options[:category]
      unless categories.is_a?(Array)
        categories = [categories]
      end
      categories.each do |category|
        obj.add_category(category)
      end
    end
    if options[:search]
      obj.ferret_create
    end
    obj
  end

  def create(name, attrs = {})
    target = 'create_' + name.to_s
    if respond_to?(target)
      send(target, attrs)
    else
      obj = build(name, attrs)
      obj.save!
      obj
    end
  end

  def build(name, attrs = {})
    data = defaults_for(name).merge(attrs)
    name.to_s.camelize.constantize.new(data)
  end

  def defaults_for(name)
    send('defaults_for_' + name.to_s.underscore) || {}
  end

  def self.num_seq
    @num_seq ||= 0
    @num_seq += 1
    @num_seq
  end

  ###### old stuff to be rearranged
  def create_admin_user(env)
    admin_user = User.find_by_login('adminuser') || create_user('adminuser', :email => 'adminuser@noosfero.org', :password => 'adminuser', :password_confirmation => 'adminuser', :environment => env)
    admin_role = Role.find_by_name('admin_role') || Role.create!(:name => 'admin_role', :permissions => ['view_environment_admin_panel','edit_environment_features', 'edit_environment_design', 'manage_environment_categories', 'manage_environment_roles', 'manage_environment_validators'])
    RoleAssignment.create!(:accessor => admin_user.person, :role => admin_role, :resource => env) unless admin_user.person.role_assignments.map{|ra|[ra.role, ra.accessor, ra.resource]}.include?([admin_role, admin_user, env])
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
  def create_user_full(name, options = {}, person_options = {})
    data = {
      :login => name,
      :email => name + '@noosfero.org',
      :password => name.underscore,
      :password_confirmation => name.underscore
    }.merge(options)
    user = User.new(data)
    user.save!
    user.person.update_attributes!(person_data.merge(person_options))
    user
  end

  def person_data
    {}
  end

  # This method knows way too much about the model. But since creating an
  # actual user is really expensive, for tests we need a fast alternative.
  def create_user(name, options = {}, person_options = {})
    environment_id = options.delete(:environment_id) || (options.delete(:environment) || Environment.default).id

    password = options.delete(:password)
    password_confirmation = options.delete(:password_confirmation)
    raise Exception.new("Passwords don't match") if (password && password_confirmation && password != password_confirmation)
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
    klass.last(:order => 'id')
  end

  def fast_insert_with_timestamps(klass, data)
    now = Time.now
    fast_insert(klass, { :created_at => now, :updated_at => now}.merge(data))
  end

  def fast_update(obj, data)
    obj.class.connection.execute('update %s set %s where id = %d' % [obj.class.table_name, ActiveRecord::Base.send(:sanitize_sql_for_assignment, data), obj.id])
  end

  def give_permission(user, permission, target)
    user = Person.find_by_identifier(user) if user.kind_of?(String)
    target ||= user
    i = 0
    while Role.find_by_name('test_role' + i.to_s)
      i+=1
    end

    role = Role.create!(:name => 'test_role' + i.to_s, :permissions => [permission])
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
    { :name => 'Environment ' + factory_num_seq.to_s }
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
    defaults_for_profile.merge({ :identifier => "person-" + n, :name => 'Person ' + n })
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
  # Article
  ###############################################

  def defaults_for_article
    name = 'My article ' + factory_num_seq.to_s
    { :name => name, :slug => name.to_slug, :path => name.to_slug }
  end

  ###############################################
  # Folder
  ###############################################

  def defaults_for_folder
    defaults_for_article
  end

  ###############################################
  # Event
  ###############################################

  def defaults_for_event
    { :name => 'My event ' + factory_num_seq.to_s, :start_date => Date.today }
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
    { :name => 'My blog ' + factory_num_seq.to_s }
  end

  def create_blog
    profile = Profile.create!(:identifier => 'testuser' + factory_num_seq.to_s, :name => 'Test user')
    Blog.create!(:name => 'blog', :profile => profile)
  end

  ###############################################
  # ExternalFeed
  ###############################################
  def defaults_for_external_feed
    { :address => RAILS_ROOT + '/test/fixtures/files/feed.xml', :blog_id => factory_num_seq }
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
    { :address => RAILS_ROOT + '/test/fixtures/files/feed.xml' }
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
    { :environment_id => Environment.default.id, :name => 'category' + factory_num_seq.to_s }
  end

  def defaults_for_region
    defaults_for_category
  end

  ###############################################
  # Box
  ###############################################
  def defaults_for_box
    { }
  end

end
