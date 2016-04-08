require 'test_helper'

class NewsletterPluginNewsletterTest < ActiveSupport::TestCase

  should 'throws exception when try to create newsletters without reference do environment' do
    assert_raises ActiveRecord::RecordInvalid do |e|
      NewsletterPlugin::Newsletter.create!
      assert_match /Profile can't be blank/, e.to_s
    end
  end

  should 'allow save only one newsletter by environment' do
    environment = fast_create Environment
    NewsletterPlugin::Newsletter.create!(:environment => environment, :person => fast_create(Person))
    assert_raises ActiveRecord::RecordInvalid do |e|
      NewsletterPlugin::Newsletter.create!(:environment => environment, :person => fast_create(Person))
      assert_match /Profile has already been taken/, e.to_s
    end
  end

  should 'collect enabled newsletters' do
    enabled_newsletters = []
    5.times do
      environment = fast_create(Environment)
      enabled = environment.id % 2 == 0
      newsletter = NewsletterPlugin::Newsletter.create!(
        :environment => environment,
        :enabled => enabled,
        :person => fast_create(Person))
      enabled_newsletters << newsletter.id if enabled
    end
    assert_equivalent enabled_newsletters, NewsletterPlugin::Newsletter.enabled.map(&:id)
  end

  should 'people of newsletters are the same environment members' do
    3.times do
      environment = fast_create(Environment)
      3.times do
        fast_create(Person, environment_id: environment)
      end
      NewsletterPlugin::Newsletter.create!(
        :environment => environment,
        :enabled => true,
        :person => fast_create(Person))
    end
    NewsletterPlugin::Newsletter.enabled.each do |newsletter|
      assert_not_equal [], newsletter.people
      assert_equal newsletter.environment.people, newsletter.people
    end
  end

  should 'save period for newsletter' do
    environment = fast_create Environment
    NewsletterPlugin::Newsletter.create!(
      :environment => environment,
      :periodicity => '3',
      :person => fast_create(Person))

    assert_equal 3, NewsletterPlugin::Newsletter.find_by(environment_id: environment.id).periodicity
  end

  should 'save period as number only' do
    environment = fast_create Environment
    assert_raises ActiveRecord::RecordInvalid do |e|
      NewsletterPlugin::Newsletter.create!(:environment => environment, :periodicity => 'one week' )
      assert_match /Periodicity must be a positive number/, e.to_s
    end
  end

  should 'save period as a positive number only' do
    environment = fast_create Environment
    assert_raises ActiveRecord::RecordInvalid do |e|
      NewsletterPlugin::Newsletter.create!(:environment => environment, :periodicity => -1 )
      assert_match /Periodicity must be a positive number/, e.to_s
    end
  end

  should 'save reference to environment blog' do
    environment = fast_create Environment
    blog = fast_create(Blog)
    blog.profile = fast_create(Profile, environment_id: environment.id)
    blog.save
    assert_nothing_raised ActiveRecord::RecordInvalid do
      NewsletterPlugin::Newsletter.create!(
        :environment => environment,
        :blog_ids => [blog.id],
        :person => fast_create(Person))
    end
  end

  should 'not save reference to unknown blog' do
    environment = fast_create Environment
    blog = fast_create(Blog)
    blog.profile = fast_create(Profile, environment_id: fast_create(Environment).id)
    blog.save
    assert_raises ActiveRecord::RecordInvalid do |e|
      NewsletterPlugin::Newsletter.create!(:environment => environment, :blog_ids => [blog.id])
      assert_match /Blog ids must be valid/, e.to_s
    end
    assert_raises ActiveRecord::RecordInvalid do |e|
      NewsletterPlugin::Newsletter.create!(:environment => environment, :blog_ids => [blog.id*2])
      assert_match /Blog ids must be valid/, e.to_s
    end
  end

  should 'not save duplicates for blog ids' do
    environment = fast_create Environment
    blog = fast_create(Blog)
    blog.profile = fast_create(Profile, environment_id: environment.id)
    blog.save
    assert_raises ActiveRecord::RecordInvalid do |e|
      NewsletterPlugin::Newsletter.create!(:environment => environment, :blog_ids => [blog.id, blog.id])
      assert_match /Blog ids must not have duplicates/, e.to_s
    end
  end

  should "not send newsletters if periodicity isn't expired" do
    newsletter = NewsletterPlugin::Newsletter.new
    newsletter.periodicity = 10
    newsletter.stubs(:last_send_at).returns(DateTime.parse("2015-01-01"))
    Date.stubs(:today).returns(Date.parse("2015-01-07"))
    assert_equal false, newsletter.must_be_sent_today?
  end

  should 'send newsletters when periodicity expires' do
    newsletter = NewsletterPlugin::Newsletter.new
    newsletter.periodicity = 10
    newsletter.stubs(:last_send_at).returns(DateTime.parse("2015-01-01"))
    Date.stubs(:today).returns(Date.parse("2015-01-15"))
    assert_equal true, newsletter.must_be_sent_today?
  end

  should 'send now if never send before' do
    newsletter = NewsletterPlugin::Newsletter.new(:environment => fast_create(Environment))
    newsletter.periodicity = 10
    assert newsletter.must_be_sent_today?
  end

  should 'validate email format for additional recipients' do
    environment = fast_create Environment
    assert_raises ActiveRecord::RecordInvalid do |e|
      NewsletterPlugin::Newsletter.create!(:environment => environment, :person => fast_create(Person), additional_recipients: [{name: 'Cooperative', email: 'cooperative@example'}])
      assert_match /Additional recipients must have only valid emails/, e.to_s
    end
    assert_nothing_raised ActiveRecord::RecordInvalid do |e|
      NewsletterPlugin::Newsletter.create!(:environment => environment, :person => fast_create(Person), additional_recipients: [{name: 'Cooperative', email: 'cooperative@example.com'}])
    end
  end

  should 'parse additional recipients' do
    content = <<-EOS
Coop1,name1@example.com
Coop2,name2@example.com
Coop3,name3@example.com
EOS

    file = Tempfile.new(['recipients', '.csv'])
    file.write(content)
    file.rewind

    environment = fast_create Environment
    newsletter = NewsletterPlugin::Newsletter.create!(:environment => environment, :person => fast_create(Person))
    newsletter.import_recipients(Rack::Test::UploadedFile.new(file, 'text/csv'))

    file.close
    file.unlink

    assert_equivalent ["name1@example.com", "name2@example.com", "name3@example.com"], newsletter.additional_recipients.map { |recipient| recipient[:email] }
    assert_equivalent ["Coop1", "Coop2", "Coop3"], newsletter.additional_recipients.map { |recipient| recipient[:name] }
  end

  should 'only parse csv files' do
    content = <<-EOS
Coop1,name1@example.com
Coop2,name2@example.com
Coop3,name3@example.com
EOS

    file = Tempfile.new(['recipients', '.txt'])
    file.write(content)
    file.rewind

    environment = fast_create Environment
    newsletter = NewsletterPlugin::Newsletter.create!(:environment => environment, :person => fast_create(Person))
    newsletter.import_recipients(Rack::Test::UploadedFile.new(file))

    file.close
    file.unlink

    assert_equal [], newsletter.additional_recipients
    assert_match /Additional recipients have unknown file type.*/, newsletter.errors.full_messages[0]
  end

  should 'parse additional recipients with given column number and header' do
    content = <<-EOS
Id,Name,City,Email
1,Coop1,Moscow,name1@example.com
2,Coop2,Beijing,name2@example.com
3,Coop3,Paris,name3@example.com
EOS

    file = Tempfile.new(['recipients', '.csv'])
    file.write(content)
    file.rewind

    environment = fast_create Environment
    newsletter = NewsletterPlugin::Newsletter.create!(:environment => environment, :person => fast_create(Person))
    newsletter.import_recipients(Rack::Test::UploadedFile.new(file, 'text/csv'), 2, 4, true)

    file.close
    file.unlink

    assert_equivalent ["name1@example.com", "name2@example.com", "name3@example.com"], newsletter.additional_recipients.map { |recipient| recipient[:email] }
    assert_equivalent ["Coop1", "Coop2", "Coop3"], newsletter.additional_recipients.map { |recipient| recipient[:name] }
  end

  should 'provide flexibility for CSV file when parsing additional recipients' do
    content_semicolon = <<-EOS
Coop1;name1@example.com
Coop2;name2@example.com
Coop3;name3@example.com
EOS

    content_tab = <<-EOS
Coop1\tname1@example.com
Coop2\tname2@example.com
Coop3\tname3@example.com
EOS
    [content_semicolon, content_tab].each do |content|
      file = Tempfile.new(['recipients', '.csv'])
      file.write(content)
      file.rewind

      environment = fast_create Environment
      newsletter = NewsletterPlugin::Newsletter.create!(:environment => environment, :person => fast_create(Person))
      newsletter.import_recipients(Rack::Test::UploadedFile.new(file, 'text/csv'))

      file.close
      file.unlink

      assert_equivalent ["name1@example.com", "name2@example.com", "name3@example.com"], newsletter.additional_recipients.map { |recipient| recipient[:email] }
      assert_equivalent ["Coop1", "Coop2", "Coop3"], newsletter.additional_recipients.map { |recipient| recipient[:name] }
    end
  end

  should 'retrieve blogs related to newsletter' do
    environment = fast_create Environment
    community = fast_create(Community, :environment_id => environment.id)
    blog1 = fast_create(Blog, :profile_id => community.id)
    blog2 = fast_create(Blog, :profile_id => community.id)
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => environment, :blog_ids => [blog1.id, blog2.id], :person => fast_create(Person)
    )
    assert_equivalent [blog1, blog2], newsletter.blogs
  end

  should 'return empty if has no related blogs' do
    environment = fast_create Environment
    newsletter = NewsletterPlugin::Newsletter.create!(:environment => environment, :person => fast_create(Person))
    assert_empty newsletter.blogs
  end

  should 'list posts for all selected blogs' do
    environment = fast_create Environment
    community = fast_create(Community, :environment_id => environment.id)
    blog = fast_create(Blog, :profile_id => community.id)
    post = fast_create(TextArticle, :parent_id => blog.id, :name => 'the last news')
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => environment,
      :blog_ids => [blog.id],
      :person => fast_create(Person))
    assert_includes newsletter.posts, post
  end

  should 'generate HTML content using posts of selected blogs' do
    environment = fast_create Environment
    community = fast_create(Community, :environment_id => environment.id)
    blog = fast_create(Blog, :profile_id => community.id)
    fast_create(TextArticle, :profile_id => community.id, :parent_id => blog.id, :name => 'the last news')
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => environment,
      :blog_ids => [blog.id],
      :person => fast_create(Person))
    assert_tag_in_string newsletter.body, :tag => 'a', :content => 'the last news'
  end

  should 'limit the number of posts per blog' do
    environment = fast_create Environment
    community = fast_create(Community, :environment_id => environment.id)
    blog = fast_create(Blog, :profile_id => community.id)
    fast_create(TextArticle, :parent_id => blog.id, :name => 'the last news 1')
    fast_create(TextArticle, :parent_id => blog.id, :name => 'the last news 2')
    fast_create(TextArticle, :parent_id => blog.id, :name => 'the last news 3')
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => environment,
      :blog_ids => [blog.id],
      :person => fast_create(Person),
      :posts_per_blog => 2)
    assert_equal 2, newsletter.posts.count
  end

  should 'include all posts before today' do
    environment = fast_create Environment
    community = fast_create(Community, :environment_id => environment.id)
    blog = fast_create(Blog, :profile_id => community.id)

    post1 = fast_create(TextArticle, :parent_id => blog.id, :name => 'the last news 1',
                :published_at => DateTime.parse("2015-01-01"))
    post2 = fast_create(TextArticle, :parent_id => blog.id, :name => 'the last news 2',
                :published_at => DateTime.parse("2015-01-09"))

    Date.stubs(:today).returns(DateTime.parse("2015-01-10").to_date)

    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => environment,
      :blog_ids => [blog.id],
      :person => fast_create(Person))

    newsletter_posts = newsletter.posts
    assert_includes newsletter_posts, post1
    assert_includes newsletter_posts, post2
  end

  should 'not include posts already sent' do
    environment = fast_create Environment
    community = fast_create(Community, :environment_id => environment.id)
    blog = fast_create(Blog, :profile_id => community.id)

    post1 = fast_create(TextArticle, :parent_id => blog.id, :name => 'the last news 1',
                :published_at => DateTime.parse("2015-01-01"))
    post2 = fast_create(TextArticle, :parent_id => blog.id, :name => 'the last news 2',
                :published_at => DateTime.parse("2015-01-09"))

    Date.stubs(:today).returns(DateTime.parse("2015-01-10").to_date)

    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => environment,
      :blog_ids => [blog.id],
      :person => fast_create(Person))
    newsletter.stubs(:last_send_at).returns(DateTime.parse("2015-01-05"))

    newsletter_posts = newsletter.posts
    assert_not_includes newsletter_posts, post1
    assert_includes newsletter_posts, post2
  end

  should 'sanitize tags <p> from news lead' do
    environment = fast_create Environment
    community = fast_create(Community, :environment_id => environment.id)
    blog = fast_create(Blog, :profile_id => community.id)
    post = fast_create(TextArticle, :parent_id => blog.id,
                :name => 'the last news 1',
                :profile_id => community.id,
                :body => '<p style="text-align: left;">paragraph of news</p>')

    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => environment,
      :blog_ids => [blog.id],
      :person => fast_create(Person))

    assert_match /<p style="text-align: left;">paragraph of news<\/p>/, post.body
    assert_no_match /<p style="text-align: left;">paragraph of news<\/p>/, newsletter.body
  end

  should 'only include text for posts in HTML generated content' do
    environment = fast_create Environment
    community = fast_create(Community, :environment_id => environment.id)
    blog = fast_create(Blog, :profile_id => community.id)
    post = fast_create(TextArticle, :profile_id => community.id, :parent_id => blog.id, :name => 'the last news', :abstract => 'A picture<img src="example.png"> is <em>worth</em> a thousand words. <hr><h1>The main goals of visualization</h1>')
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => environment,
      :blog_ids => [blog.id],
      :person => fast_create(Person))

    assert_match /A picture<img src="example.png"> is <em>worth<\/em> a thousand words. <hr><h1>The main goals of visualization<\/h1>/, post.abstract
    # Tags for text emphasis are whitelisted
    assert_match /A picture is <em>worth<\/em> a thousand words. The main goals of visualization/, newsletter.body
  end

  should 'filter posts when listing posts for newsletter' do
    person = fast_create(Person)
    blog = fast_create(Blog, profile_id: person.id)

    post_1 = fast_create(TextileArticle, :name => 'First post', :profile_id => person.id, :parent_id => blog.id, :body => 'Test')
    post_2 = fast_create(TextileArticle, :name => 'Second post', :profile_id => person.id, :parent_id => blog.id, :body => 'Test')
    post_3 = fast_create(TextileArticle, :name => 'Third post', :profile_id => person.id, :parent_id => blog.id, :body => 'Test')

    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => person.environment,
      :blog_ids => [blog.id],
      :person => person)

    assert_equivalent [post_2.id, post_3.id], newsletter.posts({post_ids: [post_2.id.to_s, post_3.id.to_s]}).map(&:id)
  end

  should 'filter posts in body for newsletter' do
    person = fast_create(Person)
    blog = fast_create(Blog, profile_id: person.id)

    post_1 = fast_create(TextileArticle, :name => 'First post', :profile_id => person.id, :parent_id => blog.id, :body => 'Test')
    post_2 = fast_create(TextileArticle, :name => 'Second post', :profile_id => person.id, :parent_id => blog.id, :body => 'Test')
    post_3 = fast_create(TextileArticle, :name => 'Third post', :profile_id => person.id, :parent_id => blog.id, :body => 'Test')

    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => person.environment,
      :blog_ids => [blog.id],
      :person => person)

    assert_match /First post/, NewsletterPlugin::Newsletter.last.body({post_ids: [post_1.id.to_s, post_3.id.to_s]})
    assert_no_match /Second post/, NewsletterPlugin::Newsletter.last.body({post_ids: [post_1.id.to_s, post_3.id.to_s]})
    assert_match /Third post/, NewsletterPlugin::Newsletter.last.body({post_ids: [post_1.id.to_s, post_3.id.to_s]})
  end

  should 'add email to unsubscribers list' do
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment),
      :person => fast_create(Person)
    )
    newsletter.unsubscribe("ze@localhost.localdomain")
    assert_includes newsletter.unsubscribers, "ze@localhost.localdomain"
  end

  should 'not add same email twice to unsubscribers list' do
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment),
      :person => fast_create(Person)
    )
    newsletter.unsubscribe("ze@localhost.localdomain")
    newsletter.unsubscribe("ze@localhost.localdomain")
    assert_equal ["ze@localhost.localdomain"], newsletter.unsubscribers
  end

  should "filter newsletter's recipients using unsubscribers list" do
    environment = fast_create Environment
    p1 = create_user("person1", :environment_id => environment.id).person
    p2 = create_user("person2", :environment_id => environment.id).person
    p3 = create_user("person3", :environment_id => environment.id).person
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => environment,
      :person => fast_create(Person)
    )
    newsletter.unsubscribe(p2.email)
    assert_equivalent [p1, p3], newsletter.people
  end

  should "no filter newsletter's recipients if unsubscribers list empty" do
    environment = fast_create Environment
    p1 = create_user("person1", :environment_id => environment.id).person
    p2 = create_user("person2", :environment_id => environment.id).person
    p3 = create_user("person3", :environment_id => environment.id).person
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => environment,
      :person => fast_create(Person)
    )
    assert_equivalent [p1, p2, p3], newsletter.people
  end

end
