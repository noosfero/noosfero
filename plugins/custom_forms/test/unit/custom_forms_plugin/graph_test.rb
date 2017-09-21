require 'test_helper'

class CustomFormsPlugin::GraphTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Profile)

    @form = CustomFormsPlugin::Form.create!(:profile => fast_create(Profile),
                                            :name => 'Free Software',
                                            :identifier => 'free')
    submission = CustomFormsPlugin::Submission.create!(:form => @form,
                                                       :profile => @profile)
    field = CustomFormsPlugin::Field.create!(:name => 'What is your favorite food?',
                                             :form => @form,
                                             :show_as => 'radio')

    CustomFormsPlugin::Alternative.create!(:field => field, :label => 'rice')
    CustomFormsPlugin::Alternative.create!(:field => field, :label => 'beans')

    alt = CustomFormsPlugin::Alternative.create!(:field => field,
                                                 :label => 'bread')

    CustomFormsPlugin::Answer.create!(:field => field,
                                      :value => alt.id,
                                      :submission => submission)


    text_field = CustomFormsPlugin::TextField.create!(:name => 'What is your name?',
                                                      :form => @form,
                                                      :show_as => 'text')

    CustomFormsPlugin::Answer.create!(:field => text_field,
                                      :value => 'My Name is Groot',
                                      :submission => submission)

  end

  attr_reader :profile, :form

  should 'calculate the user answers for a radio field' do

    graph_data = CustomFormsPlugin::Graph.new(@form).query_results

    assert_equal graph_data.class, Array
    assert_equal graph_data[0]['bread'], 1
    assert_equal graph_data[0]['rice'], 0
    assert_equal graph_data[0]['beans'], 0
    assert_equal graph_data[0]['show_as'], 'radio'
  end

  should 'Have a text answer to a text field' do
    graph_data = CustomFormsPlugin::Graph.new(form).query_results

    assert_equal graph_data[1]['answers'], ['My Name is Groot']
    assert_equal graph_data[1]['users'], [@form.profile.name]
  end
end
