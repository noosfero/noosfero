module Noosfero::Factory
  
  def fast_create(name, attrs = {})
    obj = build(name, attrs)
    obj.attributes.keys.each do |attr|
      if !obj.column_for_attribute(attr).null && obj.send(attr).nil?
        obj.send("#{attr}=", factory_num_seq)
      end
    end
    obj.save_without_validation!
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
    data = 
      if respond_to?('defaults_for_' + name.to_s)
        send('defaults_for_'+ name.to_s).merge(attrs)
      else
        attrs
      end
    eval(name.to_s.camelize).new(data)
  end

  def self.num_seq
    @num_seq ||= 0
    @num_seq += 1
    @num_seq
  end

  protected

  def factory_num_seq
    Noosfero::Factory.num_seq
  end

  ###############################################
  # Blog
  ###############################################
  def create_blog
    profile = Profile.create!(:identifier => 'testuser' + factory_num_seq.to_s, :name => 'Test user')
    Blog.create!(:name => 'blog', :profile => profile)
  end

  ###############################################
  # ExternalFeed
  ###############################################
  def defaults_for_external_feed
    { :address => RAILS_ROOT + '/test/fixtures/files/feed.xml' }
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

end
