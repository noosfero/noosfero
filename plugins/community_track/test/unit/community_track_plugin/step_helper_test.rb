require_relative '../../test_helper'

class StepHelperTest < ActiveSupport::TestCase

  include CommunityTrackPlugin::StepHelper

  def setup
    @step = CommunityTrackPlugin::Step.new
    @profile = fast_create(Community)
    @step.stubs(:profile).returns(@profile)
    @step.stubs(:active?).returns(false)
    @step.stubs(:finished?).returns(false)
    @step.stubs(:waiting?).returns(false)
  end

  should 'return active class when step is active' do
    @step.stubs(:active?).returns(true)
    assert_equal 'step_active', status_class(@step)
  end

  should 'return finished class when step is finished' do
    @step.stubs(:finished?).returns(true)
    assert_equal 'step_finished', status_class(@step)
  end

  should 'return waiting class when step is active' do
    @step.stubs(:waiting?).returns(true)
    assert_equal 'step_waiting', status_class(@step)
  end

  should 'return a description for status' do
    @step.stubs(:waiting?).returns(true)
    assert_equal _('Soon'), status_description(@step)
  end

  should 'return link to step if there is no tool in a step' do
    expects(:link_to).with(@step.view_url, {}).once
    link = link_to_step(@step) do
      "content"
    end
  end

  should 'return link to step tool if there is a tool' do
    tool = fast_create(Article, :profile_id => @profile.id)
    @step.stubs(:tool).returns(tool)
    expects(:link_to).with(tool.view_url, {}).once
    link = link_to_step(@step) do
      "content"
    end
  end

  should 'return link with name if no block is given' do
    def link_to(url, options)
      yield
    end
    link = link_to_step(@step, {}, 'link name')
    assert_equal 'link name', link
  end

end
