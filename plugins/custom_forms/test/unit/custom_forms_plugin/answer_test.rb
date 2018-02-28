require 'test_helper'

class CustomFormsPlugin::AnswerTest < ActiveSupport::TestCase
  def setup
    @profile = fast_create(Profile)
    @form = CustomFormsPlugin::Form.create!(:profile => @profile,
                                           :name => 'Free Software',
                                           :identifier => 'free')
  end
  attr_reader :form, :profile

  should 'validates presence of field' do
    answer = CustomFormsPlugin::Answer.new
    answer.valid?
    assert answer.errors.include?(:field)

    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    answer.field = field
    answer.valid?
    refute answer.errors.include?(:field)
  end

  should 'belong to a submission' do
    submission = CustomFormsPlugin::Submission.create!(:form => form, :profile => fast_create(Profile))
    answer = CustomFormsPlugin::Answer.new
    answer.submission = submission

    assert_equal submission, answer.submission
  end

  should 'require presence of value if field is mandatory' do
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form, :mandatory => true)
    answer = CustomFormsPlugin::Answer.new(:field => field)
    answer.valid?
    assert answer.errors.include?(:value)

    answer.value = "GPL"
    answer.valid?
    refute answer.errors.include?(:value)
  end

  should 'make string representation show answers' do
    field = CustomFormsPlugin::Field.create!(:name => 'ProjectName', :form => form)
    answer = CustomFormsPlugin::Answer.new(:field => field, :value => 'MyProject')

    field_select = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    alt = CustomFormsPlugin::Alternative.create!(:id => 1, :field => field_select, :label => 'GPL')
    answer2 = CustomFormsPlugin::Answer.new(:field => field_select, :value => alt.id.to_s)

    assert_equal 'MyProject', answer.to_s
    assert_equal 'GPL', answer2.to_s
  end

  should 'validate if answer is one of the alternatives' do
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    alt = CustomFormsPlugin::Alternative.create!(:field => field, :label => 'GPL')
    answer = CustomFormsPlugin::Answer.new(:field => field, :value => alt.id)
    assert answer.valid?
  end

  should 'not validate if answer is not one of the alternatives' do
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    CustomFormsPlugin::Alternative.create!(:field => field, :label => 'GPL')
    answer = CustomFormsPlugin::Answer.new(:field => field, :value => "invalid")
    refute answer.valid?
  end

  should 'validate if field accepts multiple alternatives' do
    field = CustomFormsPlugin::Field.create!(name: 'License', form: form, show_as: 'check_box')
    a1 = CustomFormsPlugin::Alternative.create!(field: field, label: 'GPL')
    a2 = CustomFormsPlugin::Alternative.create!(field: field, label: 'MIT')
    answer = CustomFormsPlugin::Answer.new(field: field, value: "#{a1.id},#{a2.id}")
    assert answer.valid?
  end

  should 'not validate if field does not accept multiple alternatives' do
    field = CustomFormsPlugin::Field.create!(name: 'License', form: form, show_as: 'radio')
    a1 = CustomFormsPlugin::Alternative.create!(field: field, label: 'GPL')
    a2 = CustomFormsPlugin::Alternative.create!(field: field, label: 'MIT')
    answer = CustomFormsPlugin::Answer.new(field: field, value: "#{a1.id},#{a2.id}")
    refute answer.valid?
  end

  should 'replace semicolons in the labels with dots' do
    field = form.fields.create!(:name => 'License')
    alt1 = field.alternatives.create!(:label => 'An answer;')
    alt2 = field.alternatives.create!(:label => 'Other answer;')
    answer = field.answers.new(:value => "#{alt1.id},#{alt2.id}")
    assert_equal 'An answer.;Other answer.', answer.to_s
  end

end

