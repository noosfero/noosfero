require 'test_helper'

class CustomFormsPlugin::GraphTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Profile)
    @profile2 = fast_create(Profile)

    @form = CustomFormsPlugin::Form.create!(:profile => @profile,
                                            :name => 'Free Software',
                                            :identifier => 'free')
    submission = CustomFormsPlugin::Submission.create!(:form => @form,
                                                       :profile => @profile)
    submission2 = CustomFormsPlugin::Submission.create!(:form => @form,
                                                       :profile => @profile2)
    radio_field = CustomFormsPlugin::Field.create!(
      :name => 'What is your favorite food?',
      :form => @form,
      :show_as => 'radio'
    )


    CustomFormsPlugin::Alternative.create!(:field => radio_field,
                                           :label => 'rice')
    CustomFormsPlugin::Alternative.create!(:field => radio_field,
                                           :label => 'beans')

    alt = CustomFormsPlugin::Alternative.create!(:field => radio_field,
                                                 :label => 'bread')

    CustomFormsPlugin::Answer.create!(:field => radio_field,
                                      :value => alt.id,
                                      :submission => submission)

    CustomFormsPlugin::Answer.create!(:field => radio_field,
                                      :value => alt.id,
                                      :submission => submission2)

    check_box_field = CustomFormsPlugin::Field.create!(
      :name => 'Which notebook marks do you already had?',
      :form => @form,
      :show_as => 'check_box'
    )

    check_alt = CustomFormsPlugin::Alternative.create!(
      :field => check_box_field, :label => 'azus'
    )
    check_alt1 = CustomFormsPlugin::Alternative.create!(
      :field => check_box_field, :label => 'acer'
    )
    check_alt2 = CustomFormsPlugin::Alternative.create!(
      :field => check_box_field, :label => 'mac'
    )
    check_alt3 = CustomFormsPlugin::Alternative.create!(
      :field => check_box_field, :label => 'dell'
    )

    CustomFormsPlugin::Answer.create!(:field => check_box_field,
                                      :value => "#{check_alt1.id},#{check_alt2.id}",
                                      :submission => submission)

    CustomFormsPlugin::Answer.create!(:field => check_box_field,
                                      :value => "#{check_alt1.id},#{check_alt3.id}",
                                      :submission => submission2)

    text_field = CustomFormsPlugin::TextField.create!(:name => 'What is your name?',
                                                      :form => @form,
                                                      :show_as => 'text')

    CustomFormsPlugin::Answer.create!(:field => text_field,
                                      :value => 'My Name is Groot',
                                      :submission => submission)

    CustomFormsPlugin::Answer.create!(:field => text_field,
                                      :value => 'My Name is David',
                                      :submission => submission2)
  end

  attr_reader :profile, :form

  should 'calculate the user answers for a radio field' do

    graph_data = CustomFormsPlugin::Graph.new(@form).query_results

    assert_equal graph_data.class, Array
    assert_equal graph_data[0]['data']['bread'], 2
    assert_equal graph_data[0]['data']['rice'], 0
    assert_equal graph_data[0]['data']['beans'], 0
    assert_equal graph_data[0]['data']['show_as'], 'radio'
  end

  should 'calculate the user answers for a check_box field' do

    graph_data = CustomFormsPlugin::Graph.new(@form).query_results

    assert_equal graph_data.class, Array
    assert_equal graph_data[1]['data']['azus'], 0
    assert_equal graph_data[1]['data']['acer'], 2
    assert_equal graph_data[1]['data']['mac'], 1
    assert_equal graph_data[1]['data']['dell'], 1
    assert_equal graph_data[1]['data']['show_as'], 'check_box'
  end

  should 'Have a text answer to a text field' do
    graph_data = CustomFormsPlugin::Graph.new(form).query_results

    assert_equal graph_data[2]['data']['answers'].first, 'My Name is Groot'
    assert_equal graph_data[2]['data']['users'].first, profile.name
  end
end
