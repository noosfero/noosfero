require 'test_helper'

class CustomFormsPlugin::ListLinkBlock < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @user = create_user('admin').person
    @profile.add_admin(@user)
    @polls_block = CustomFormsPlugin::PollsBlock.new
    @surveys_block = CustomFormsPlugin::SurveyBlock.new

    CustomFormsPlugin::PollsBlock.any_instance.stubs(:owner).returns(@profile)
    CustomFormsPlugin::SurveyBlock.any_instance.stubs(:owner).returns(@profile)
  end

  should 'list forms of the profile owner' do
    alternative_a = CustomFormsPlugin::Alternative.new(:label => 'A')
    alternative_b = CustomFormsPlugin::Alternative.new(:label => 'B')

    profile2 = fast_create(Community)

    poll1 = CustomFormsPlugin::Form.new(profile: @profile, name: 'F1', kind: 'poll')
    field1 = CustomFormsPlugin::SelectField.new(:name => 'Question 1')
    field1.alternatives= [alternative_a, alternative_b]
    poll1.fields= [field1]
    poll1.save!

    poll2 = CustomFormsPlugin::Form.new(profile: profile2, name: 'F1', kind: 'poll')
    field2 = CustomFormsPlugin::SelectField.new(:name => 'Question 1')
    field2.alternatives= [alternative_a, alternative_b]
    poll2.fields= [field2]
    poll2.save!

    assert_equivalent [poll1], @polls_block.list_forms(@user)

    survey1 = CustomFormsPlugin::Form.create!(profile: @profile, name: 'F2', kind: 'survey')
    survey2 = CustomFormsPlugin::Form.create!(profile: profile2, name: 'F2', kind: 'survey')
    assert_equivalent [survey1], @surveys_block.list_forms(@user)
  end

  should 'return forms according to the block type' do
    alternative_a = CustomFormsPlugin::Alternative.new(:label => 'A')
    alternative_b = CustomFormsPlugin::Alternative.new(:label => 'B')

    poll = CustomFormsPlugin::Form.new(profile: @profile, name: 'F1', kind: 'poll')
    field = CustomFormsPlugin::SelectField.new(:name => 'Question 1')
    field.alternatives= [alternative_a, alternative_b]
    poll.fields= [field]
    poll.save!

    survey = CustomFormsPlugin::Form.create!(profile: @profile, name: 'F2', kind: 'survey')

    assert_equivalent [poll], @polls_block.list_forms(@user)
    assert_equivalent [survey], @surveys_block.list_forms(@user)
  end

  should 'return all block statuses by default' do
    assert_equal 'all', @polls_block.status
    assert_equal 'all', @surveys_block.status
  end

  should 'return three forms by default' do
    assert_equal 3, @polls_block.limit
    assert_equal 3, @surveys_block.limit
  end

  should 'limit listed forms using block limit' do
    @surveys_block.metadata['limit'] = 2
    3.times do |count|
      CustomFormsPlugin::Form.create!(profile: @profile, name: "F#{count}", kind: 'survey')
    end
    assert_equal 2, @surveys_block.list_forms(@user).count
  end

  should 'order forms by ending date' do
    @polls_block.metadata['limit'] = 4
    alternative_a = CustomFormsPlugin::Alternative.new(:label => 'A')
    alternative_b = CustomFormsPlugin::Alternative.new(:label => 'B')

    poll1 = CustomFormsPlugin::Form.new(profile: @profile, name: 'F1', kind: 'poll', ending: 1.days.ago)
    field1 = CustomFormsPlugin::SelectField.new(:name => 'Question 1')
    field1.alternatives= [alternative_a, alternative_b]
    poll1.fields= [field1]
    poll1.save!

    poll2 = CustomFormsPlugin::Form.new(profile: @profile, name: 'F2', kind: 'poll', ending: nil)
    field2 = CustomFormsPlugin::SelectField.new(:name => 'Question 1')
    field2.alternatives= [alternative_a, alternative_b]
    poll2.fields= [field2]
    poll2.save!

    poll3 = CustomFormsPlugin::Form.new(profile: @profile, name: 'F3', kind: 'poll', ending: 2.days.from_now)
    field3 = CustomFormsPlugin::SelectField.new(:name => 'Question 1')
    field3.alternatives= [alternative_a, alternative_b]
    poll3.fields= [field3]
    poll3.save!

    poll4 = CustomFormsPlugin::Form.new(profile: @profile, name: 'F4', kind: 'poll', ending: 3.days.ago)
    field4 = CustomFormsPlugin::SelectField.new(:name => 'Question 1')
    field4.alternatives= [alternative_a, alternative_b]
    poll4.fields= [field4]
    poll4.save!

    assert_equal [poll4, poll1, poll3, poll2], @polls_block.list_forms(@user)
  end

end
