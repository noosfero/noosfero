require 'test_helper'

class NewsletterPluginAdminControllerTest < ActionController::TestCase

  def setup
    @controller = NewsletterPluginAdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @admin = create_user('admin_newsletter').person
    @environment = @admin.environment
    @environment.add_admin(@admin)

    @environment.enable_plugin(NewsletterPlugin)
    @controller.stubs(:environment).returns(@environment)
  end

  should 'allow access to admin' do
    login_as @admin.identifier
    get :index
    assert_response :success
  end

  should 'save footer setting' do
    login_as @admin.identifier
    post :index,
      :newsletter => { :footer => 'footer of newsletter' }

    assert_equal 'footer of newsletter', assigns(:newsletter).footer
  end


  should 'save header image' do
    login_as @admin.identifier
    post :index,
      :newsletter => {
        :image_builder => {
          :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
        }
      }
    assert_equal 'rails.png', assigns(:newsletter).image.filename
  end

  should 'save enabled newsletter information' do
    login_as @admin.identifier
    post :index,
      :newsletter => { :enabled => 'true' }

    newsletter = NewsletterPlugin::Newsletter.find_by environment_id: @environment.id

    assert newsletter.enabled
  end

  should 'save periodicity newsletter information' do
    login_as @admin.identifier
    post :index,
      :newsletter => { :periodicity => '10' }

    newsletter = NewsletterPlugin::Newsletter.find_by environment_id: @environment.id

    assert_equal 10, newsletter.periodicity
  end

  should 'save number of posts per blog setting' do
    login_as @admin.identifier
    post :index,
      :newsletter => { :posts_per_blog => '6' }

    assert_equal 6, assigns(:newsletter).posts_per_blog
  end

  should 'show error if number of posts per blog is not a positive number' do
    login_as @admin.identifier
    post :index,
      :newsletter => { :posts_per_blog => '-4' }

    assert_select 'li', 'Posts per blog must be a positive number'
  end

  should 'save blogs for compiling newsletter setting' do
    login_as @admin.identifier

    blog1 = fast_create(Blog)
    blog1.profile = fast_create(Profile, environment_id: @environment.id)
    blog1.save

    blog2 = fast_create(Blog)
    blog2.profile = fast_create(Profile, environment_id: @environment.id)
    blog2.save

    post :index,
      :newsletter => { :blog_ids => "#{blog1.id},#{blog2.id}" }

    assert_equivalent [blog1.id,blog2.id], assigns(:newsletter).blog_ids
  end

  should 'show error if blog is not in environment' do
    login_as @admin.identifier

    blog = fast_create(Blog)
    blog.profile = fast_create(Profile, environment_id: fast_create(Environment).id)
    blog.save

    post :index,
      :newsletter => { :blog_ids => "#{blog.id}" }

    assert_select 'li', 'Blog ids must be valid'
  end

  should 'save logged in admin as person' do
    login_as @admin.identifier
    post :index, :newsletter => { }

    assert_equal @admin, assigns(:newsletter).person
  end

  should 'receive csv file from user' do
    content = <<-EOS
Coop1,name1@example.com
Coop2,name2@example.com
Coop3,name3@example.com
EOS

    file = Tempfile.new(['recipients', '.csv'])
    file.write(content)
    file.rewind

    login_as @admin.identifier
    post :index, newsletter: {}, :file => { recipients: Rack::Test::UploadedFile.new(file, 'text/csv') }

    file.close
    file.unlink

    assert_equivalent ["name1@example.com", "name2@example.com", "name3@example.com"], assigns(:newsletter).additional_recipients.map { |recipient| recipient[:email] }
    assert_equivalent ["Coop1", "Coop2", "Coop3"], assigns(:newsletter).additional_recipients.map { |recipient| recipient[:name] }
  end

  should 'parse csv file with configuration set by user' do
    content = <<-EOS
Id,Name,City,Email
1,Coop1,Moscow,name1@example.com
2,Coop2,Beijing,name2@example.com
3,Coop3,Paris,name3@example.com
EOS

    file = Tempfile.new(['recipients', '.csv'])
    file.write(content)
    file.rewind

    login_as @admin.identifier
    post :index, newsletter: {}, :file => { recipients: Rack::Test::UploadedFile.new(file, 'text/csv'), headers: 1, name: 2, email: 4 }

    file.close
    file.unlink

    assert_equivalent ["name1@example.com", "name2@example.com", "name3@example.com"], assigns(:newsletter).additional_recipients.map { |recipient| recipient[:email] }
    assert_equivalent ["Coop1", "Coop2", "Coop3"], assigns(:newsletter).additional_recipients.map { |recipient| recipient[:name] }
  end

  should 'list additional recipients' do
    login_as @admin.identifier
    get :recipients
    assert_select 'p', 'There are no additional recipients.'

    newsletter = NewsletterPlugin::Newsletter.create!(environment: @environment, person: fast_create(Person))
    newsletter.additional_recipients = [ {name: 'Coop1', email: 'name1@example.com'} ]
    newsletter.save!

    get :recipients
    assert_select 'tr' do
      assert_select 'td', 'Coop1'
      assert_select 'td', 'name1@example.com'
    end
  end

end
