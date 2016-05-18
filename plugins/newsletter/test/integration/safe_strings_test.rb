require 'test_helper'

class NewsletterPluginSafeStringsTest < ActionDispatch::IntegrationTest

  should 'not escape HTML from newsletter pending task' do
    environment = Environment.default
    environment.enable_plugin('newsletter')
    person = create_user('john', :environment_id => environment.id, :password => 'test', :password_confirmation => 'test').person
    person.user.activate
    environment.add_admin(person)

    blog = fast_create(Blog, :profile_id => person.id)
    post = fast_create(TextileArticle, :name => 'First post', :profile_id => person.id, :parent_id => blog.id, :body => 'Test')
    newsletter = NewsletterPlugin::Newsletter.create!(:environment => environment, :person => person, :enabled => true)
    newsletter.blog_ids = [blog.id]
    newsletter.save!
    task = NewsletterPlugin::ModerateNewsletter.create!(
      :newsletter_id => newsletter.id,
      :target => environment,
      :post_ids => [post.id.to_s]
    )

    login 'john', 'test'
    get '/myprofile/john/tasks'

    assert_tag :tag => 'input',
      :attributes => { :type => 'checkbox', :name => "tasks[#{task.id}][task][post_ids][]" },
      :sibling => { :tag => 'span' }
  end

end
