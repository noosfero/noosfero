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

    radio_alt_1 = CustomFormsPlugin::Alternative.create!(:field => @radio_field,
                                                 :label => 'bread')
    radio_alt_2 = CustomFormsPlugin::Alternative.create!(:field => @radio_field,
                                           :label => 'rice')
    radio_alt_3 = CustomFormsPlugin::Alternative.create!(:field => @radio_field,
                                           :label => 'beans')

    answer_1 = CustomFormsPlugin::Answer.create!(:field => @radio_field,
                                                 :value => '',
                                                 :submission => submission)
    answer_2 = CustomFormsPlugin::Answer.create!(:field => @radio_field,
                                                 :value => '',
                                                 :submission => submission2)

    form_answer_1 = CustomFormsPlugin::FormAnswer.create!(:alternative_id => radio_alt_1.id,
                                                          :answer_id => answer_1.id)
    form_answer_2 = CustomFormsPlugin::FormAnswer.create!(:alternative_id => radio_alt_1.id,
                                                          :answer_id => answer_2.id)

    @check_box_field = CustomFormsPlugin::Field.create!(
      :name => 'Which laptop marks do you already had?',
      :form => @form,
      :show_as => 'check_box'
    )

    check_alt_1 = CustomFormsPlugin::Alternative.create!(
      :field => @check_box_field, :label => 'azus'
    )
    check_alt_2 = CustomFormsPlugin::Alternative.create!(
      :field => @check_box_field, :label => 'acer'
    )
    check_alt_3 = CustomFormsPlugin::Alternative.create!(
      :field => @check_box_field, :label => 'mac'
    )
    check_alt_4 = CustomFormsPlugin::Alternative.create!(
      :field => @check_box_field, :label => 'dell'
    )

    answer_3 = CustomFormsPlugin::Answer.create!(:field => @check_box_field,
                                      :value => "",
                                      :submission => submission)

    answer_4 = CustomFormsPlugin::Answer.create!(:field => @check_box_field,
                                      :value => "",
                                      :submission => submission2)

    form_answer_3 = CustomFormsPlugin::FormAnswer.create!(:alternative_id => check_alt_2.id,
                                                          :answer_id => answer_3.id)
    form_answer_4 = CustomFormsPlugin::FormAnswer.create!(:alternative_id => check_alt_3.id,
                                                          :answer_id => answer_3.id)
    form_answer_5 = CustomFormsPlugin::FormAnswer.create!(:alternative_id => check_alt_2.id,
                                                          :answer_id => answer_4.id)
    form_answer_6 = CustomFormsPlugin::FormAnswer.create!(:alternative_id => check_alt_4.id,
                                                          :answer_id => answer_4.id)

    @text_field = CustomFormsPlugin::TextField.create!(:name => 'What is your name?',
                                                      :form => @form,
                                                      :show_as => 'text')

    @text_answer = CustomFormsPlugin::Answer.create!(:field => @text_field,
                                      :value => 'My Name is Groot',
                                      :submission => submission)

    @text_answer_2 = CustomFormsPlugin::Answer.create!(:field => @text_field,
                                      :value => 'My Name is David',
                                      :submission => submission2)

    @radio_alternatives = [radio_alt_1, radio_alt_2, radio_alt_3]
    @check_alternatives = [check_alt_1, check_alt_2, check_alt_3, check_alt_4]
  end

  attr_reader :profile, :profile2, :form, :text_field, :check_box_field, :radio_field,
              :text_answer, :text_answer_2, :radio_alternatives, :check_alternatives

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
    answers_count = select_fields.map(&:answer_count).reduce(:+)

    assert field_names.include? check_box_field.name
    assert field_names.include? radio_field.name
    assert_equal answers_count, CustomFormsPlugin::FormAnswer.count
  end

  should "format fields" do
    graph = CustomFormsPlugin::Graph.new(form)
    formated_fields = graph.query_results

    template = [
      {
        "data"=>{
          radio_alternatives[0].label=>radio_alternatives[0].answers.count,
          radio_alternatives[1].label=>radio_alternatives[1].answers.count,
          radio_alternatives[2].label=>radio_alternatives[2].answers.count
        },
        "field"=> radio_field.name,
        "show_as"=>"pizza",
        "summary"=>{}
      },
      {
        "data"=>{
          check_alternatives[0].label=>check_alternatives[0].answers.count,
          check_alternatives[1].label=>check_alternatives[1].answers.count,
          check_alternatives[2].label=>check_alternatives[2].answers.count,
          check_alternatives[3].label=>check_alternatives[3].answers.count
        },
        "field"=> check_box_field.name,
        "show_as"=>"column",
        "summary"=>{}
      },
      {
        "data"=> {
          "answers"=>[text_answer.value, text_answer_2.value],
          "users"=>[profile.name, profile2.name],
          "imported"=>[text_answer_2.imported.to_s, text_answer_2.imported.to_s]},
        "show_as"=>"text",
        "field"=> text_field.name
      }
    ]

    assert_equal formated_fields, template
  end

  should 'calculate the user answers for a radio field' do
    graph_data = CustomFormsPlugin::Graph.new(@form).query_results

    assert_equal graph_data.class, Array
    assert_equal graph_data[0]['data']['bread'], 2
    assert_equal graph_data[0]['data']['rice'], 0
    assert_equal graph_data[0]['data']['beans'], 0
    assert_equal graph_data[0]['show_as'], 'pizza'
    refute graph_data[0]['summary'].present? # TODO: reimplement the summary feature
  end

  should 'calculate the user answers for a check_box field' do
    graph_data = CustomFormsPlugin::Graph.new(@form).query_results

    assert_equal graph_data.class, Array
    assert_equal graph_data[1]['data']['azus'], 0
    assert_equal graph_data[1]['data']['acer'], 2
    assert_equal graph_data[1]['data']['mac'], 1
    assert_equal graph_data[1]['data']['dell'], 1
    assert_equal graph_data[1]['show_as'], 'column'
    refute graph_data[1]['summary'].present? # TODO: reimplement the summary feature
  end

  should 'Have a text answer to a text field' do
    graph_data = CustomFormsPlugin::Graph.new(form).query_results

    assert_equal graph_data[2]['data']['answers'].first, 'My Name is Groot'
    assert_equal graph_data[2]['data']['users'].first, profile.name
  end
end
