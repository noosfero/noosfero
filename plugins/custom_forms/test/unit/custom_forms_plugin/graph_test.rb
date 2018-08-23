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
    @radio_field = CustomFormsPlugin::Field.create!(
      :name => 'What is your favorite food?',
      :form => @form,
      :show_as => 'radio'
    )

    alternative_1 = CustomFormsPlugin::Alternative.create!(:field => @radio_field,
                                           :label => 'rice')
    alternative_2 = CustomFormsPlugin::Alternative.create!(:field => @radio_field,
                                           :label => 'beans')
    alternative_3 = CustomFormsPlugin::Alternative.create!(:field => @radio_field,
                                                 :label => 'bread')
    answer_1 = CustomFormsPlugin::Answer.create!(:field => @radio_field,
                                                 :value => alternative_3.id,
                                                 :submission => submission)
    answer_2 = CustomFormsPlugin::Answer.create!(:field => @radio_field,
                                                 :value => alternative_3.id,
                                                 :submission => submission2)
    form_answer_1 = CustomFormsPlugin::FormAnswer.create!(:alternative_id => alternative_1.id,
                                                          :answer_id => answer_1.id)
    form_answer_2 = CustomFormsPlugin::FormAnswer.create!(:alternative_id => alternative_2.id,
                                                          :answer_id => answer_2.id)

    @check_box_field = CustomFormsPlugin::Field.create!(
      :name => 'Which laptop marks do you already had?',
      :form => @form,
      :show_as => 'check_box'
    )

    check_alt = CustomFormsPlugin::Alternative.create!(
      :field => @check_box_field, :label => 'azus'
    )
    check_alt1 = CustomFormsPlugin::Alternative.create!(
      :field => @check_box_field, :label => 'acer'
    )
    check_alt2 = CustomFormsPlugin::Alternative.create!(
      :field => @check_box_field, :label => 'mac'
    )
    check_alt3 = CustomFormsPlugin::Alternative.create!(
      :field => @check_box_field, :label => 'dell'
    )

    answer_3 = CustomFormsPlugin::Answer.create!(:field => @check_box_field,
                                      :value => "#{check_alt1.id},#{check_alt2.id}",
                                      :submission => submission)

    answer_4 = CustomFormsPlugin::Answer.create!(:field => @check_box_field,
                                      :value => "#{check_alt1.id},#{check_alt3.id}",
                                      :submission => submission2)

    form_answer_3 = CustomFormsPlugin::FormAnswer.create!(:alternative_id => alternative_3.id,
                                                          :answer_id => answer_3.id)

    form_answer_4 = CustomFormsPlugin::FormAnswer.create!(:alternative_id => alternative_3.id,
                                                          :answer_id => answer_4.id)

    @text_field = CustomFormsPlugin::TextField.create!(:name => 'What is your name?',
                                                      :form => @form,
                                                      :show_as => 'text')

    CustomFormsPlugin::Answer.create!(:field => @text_field,
                                      :value => 'My Name is Groot',
                                      :submission => submission)

    CustomFormsPlugin::Answer.create!(:field => @text_field,
                                      :value => 'My Name is David',
                                      :submission => submission2)
  end

  attr_reader :profile, :form, :text_field, :check_box_field, :radio_field

  should "return right chart type" do
    graph = CustomFormsPlugin::Graph.new(form)

    ["radio", "select"].each do |option|
      assert_equal "pizza", graph.chart_to_show_data(option)
    end

    ["check_box", "multiple_select"].each do |option|
      assert_equal "column", graph.chart_to_show_data(option)
    end

    assert_equal "text", graph.chart_to_show_data("text")
  end

  should "get text fields" do 
    graph = CustomFormsPlugin::Graph.new(form)
    text_fields = graph.send(:get_text_fields)

    users = (text_fields.map {|f| f.users.split(',')}).flatten
    fields_ids = text_fields.map(&:id)

    assert fields_ids.include? text_field.id
    assert users.include? @profile.name
    assert users.include? @profile2.name
  end

  should "get select fields" do 
    graph = CustomFormsPlugin::Graph.new(form)
    select_fields = graph.send(:get_select_fields)
    field_names = select_fields.map(&:field_name).uniq
    answer_count = select_fields.map(&:answer_count).reduce(:+)

    assert field_names.include? check_box_field.name
    assert field_names.include? radio_field.name
    assert_equal answer_count, CustomFormsPlugin::FormAnswer.count
  end

  should "format data to build graph" do

  end

  should 'calculate the user answers for a radio field' do
    graph_data = CustomFormsPlugin::Graph.new(@form).query_results

    assert_equal graph_data.class, Array
    assert_equal graph_data[0]['data']['bread'], 2
    assert_equal graph_data[0]['data']['rice'], 0
    assert_equal graph_data[0]['data']['beans'], 0
    assert_equal graph_data[0]['show_as'], 'radio'
    assert graph_data[0]['summary'].present?
  end

  should 'calculate the user answers for a check_box field' do
    graph_data = CustomFormsPlugin::Graph.new(@form).query_results

    assert_equal graph_data.class, Array
    assert_equal graph_data[1]['data']['azus'], 0
    assert_equal graph_data[1]['data']['acer'], 2
    assert_equal graph_data[1]['data']['mac'], 1
    assert_equal graph_data[1]['data']['dell'], 1
    assert_equal graph_data[1]['show_as'], 'check_box'
    assert graph_data[1]['summary'].present?
  end

  should 'Have a text answer to a text field' do
    graph_data = CustomFormsPlugin::Graph.new(form).query_results

    assert_equal graph_data[2]['data']['answers'].first, 'My Name is Groot'
    assert_equal graph_data[2]['data']['users'].first, profile.name
  end
end
