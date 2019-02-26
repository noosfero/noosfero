require_relative "../test_helper"

class TaskHelperTest < ActionView::TestCase

  include ApplicationHelper

  def setup
    @profile = fast_create(Profile)
    @task = fast_create(Task, :target_id => @profile.id)
  end

  attr_accessor :task, :profile

  should 'return select field for template selection when there is templates to choose' do
    email_templates = 3.times.map { EmailTemplate.new }
    assert_tag_in_string task_email_template('Description', email_templates, task), :tag => 'div', :attributes => {:class => 'template-selection'}
  end

  should 'not return select field for template selection when there is no templates to choose' do
    assert task_email_template('Description', [], task).blank?
  end

end
