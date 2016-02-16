require 'test_helper'

class NewsletterPluginModerateNewsletterTest < ActiveSupport::TestCase

  should 'validates presence of newsletter_id' do
    task = NewsletterPlugin::ModerateNewsletter.new
    task.valid?
    assert task.errors.include?(:newsletter_id)

    task.newsletter_id = 1
    task.valid?
    refute task.errors.include?(:newsletter_id)
  end

  should 'create mailing on perform' do
    person = create_user('john').person
    newsletter = NewsletterPlugin::Newsletter.create!(:environment => fast_create(Environment), :person => person, :enabled => true)
    task = NewsletterPlugin::ModerateNewsletter.create!(
      :newsletter_id => newsletter.id,
      :target => newsletter.environment
    )

    assert_difference 'NewsletterPlugin::NewsletterMailing.count', 1 do
      task.finish
    end
  end

  should 'set posts for mailing body on perform' do
    person = create_user('john').person
    blog = fast_create(Blog, profile_id: person.id)
    post_1 = fast_create(TextileArticle, :name => 'First post', :profile_id => person.id, :parent_id => blog.id, :body => 'Test')
    post_2 = fast_create(TextileArticle, :name => 'Second post', :profile_id => person.id, :parent_id => blog.id, :body => 'Test')
    post_3 = fast_create(TextileArticle, :name => 'Third post', :profile_id => person.id, :parent_id => blog.id, :body => 'Test')

    newsletter = NewsletterPlugin::Newsletter.create!(:environment => person.environment, :person => person, :enabled => true)
    newsletter.blog_ids = [blog.id]
    newsletter.save!

    task = NewsletterPlugin::ModerateNewsletter.create!(
      :newsletter_id => newsletter.id,
      :target => newsletter.environment,
      :post_ids => [post_1.id.to_s,post_2.id.to_s]
    )

    task.finish
    assert_match /First post/, NewsletterPlugin::NewsletterMailing.last.body
    assert_match /Second post/, NewsletterPlugin::NewsletterMailing.last.body
    assert_no_match /Third post/, NewsletterPlugin::NewsletterMailing.last.body
  end
end
