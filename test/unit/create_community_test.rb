require_relative "../test_helper"

class CreateCommunityTest < ActiveSupport::TestCase

  def setup
    @person = create_user('testing').person
  end
  attr_reader :person

  should 'provide needed data' do
    task = CreateCommunity.new

    Community.fields + %w[ name closed tag_list ].each do |field|
      assert task.respond_to?(field)
      assert task.respond_to?("#{field}=")
    end
  end

  should 'require a requestor' do
    task = CreateCommunity.new(:name => 'community test', :target => Environment.default)
    task.valid?

    assert task.errors[:requestor_id.to_s].present?
    task.requestor = person
    task.valid?
    refute task.errors[:requestor_id.to_s].present?
  end

  should 'actually create a community when finishing the task and associate the task requestor as its admin' do

    task = CreateCommunity.create!({
      :name => 'My new community',
      :requestor => person,
      :target => Environment.default,
    })

    assert_difference 'Community.count' do
      task.finish
    end

    assert_equal person, Community['my-new-community'].admins.first
  end

  should 'override message methods from Task' do
    specific = CreateCommunity.new
    %w[ task_created_message task_finished_message task_cancelled_message ].each do |method|
      assert_nothing_raised NotImplementedError do
        specific.send(method)
      end
    end
  end

  should 'provide a message to be sent to the target' do
    assert_not_nil CreateCommunity.new(:name => 'test comm', :requestor => person).target_notification_message
  end

  should 'report as approved when approved' do
    request = CreateCommunity.new
    request.stubs(:status).returns(Task::Status::FINISHED)
    assert request.approved?
  end

  should 'report as rejected when rejected' do
    request = CreateCommunity.new
    request.stubs(:status).returns(Task::Status::CANCELLED)
    assert request.rejected?
  end

  should 'create a community with image when finishing the task' do

    task = CreateCommunity.create!({
      :name => 'My new community',
      :requestor => person,
      :target => Environment.default,
      :image_builder => {:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')}
    })

    assert_equal 'rails.png', task.image.filename
    assert_difference 'Community.count' do
      task.finish
    end

    assert_equal 'rails.png', Community['my-new-community'].image.filename
  end

  should 'have target notification message' do
    task = CreateCommunity.new(:name => 'community test', :target => Environment.default, :requestor => person)

    assert_match(/requested to create community.*to approve or reject/, task.target_notification_message)
  end

  should 'have target notification description' do
    task = CreateCommunity.new(:name => 'community test', :target => Environment.default, :requestor => person)

    assert_match(/#{task.requestor.name} wants to create community #{task.subject}/, task.target_notification_description)
  end

  should 'deliver target notification message' do
    task = CreateCommunity.new(:name => 'community test', :target => Environment.default, :requestor => person)

    email = TaskMailer.target_notification(task, task.target_notification_message).deliver
    assert_match(/#{task.requestor.name} wants to create community #{task.subject}/, email.subject)
  end

end
