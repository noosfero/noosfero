require 'test_helper'

class CustomFormsPlugin::CsvHandlerTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Profile)
    @form = @profile.forms.create!(name: 'Free Software', identifier: 'free')
    @handler = CustomFormsPlugin::CsvHandler.new(@form)
  end

  should 'include the default fields in the tempalte' do
    template = @handler.generate_template
    CustomFormsPlugin::CsvHandler::DEFAULT_COLUMNS.each do |col|
      assert_match /#{col}/, template
    end
  end

  should 'include all fields in the generated template' do
    f1 = CustomFormsPlugin::TextField.create!(form: @form, name: 'Priority')
    f2 = CustomFormsPlugin::TextField.create!(form: @form, name: 'Description')
    template = @handler.generate_template
    assert /#{f1.name}/, template
    assert /#{f2.name}/, template
  end

  should 'include field and alternatives for select fields' do
    field = CustomFormsPlugin::SelectField.new(form: @form, name: 'OS')
    a1 = field.alternatives.new(label: 'Debian')
    a2 = field.alternatives.new(label: 'Ubuntu')
    field.alternatives = [a1, a2]
    field.save!

    template = @handler.generate_template
    assert_match /#{field.name}/, template
    assert_match /#{a1.label}/, template
    assert_match /#{a2.label}/, template
  end

  should 'include default columns in the generated CSV' do
    content = @handler.generate_csv
    CustomFormsPlugin::CsvHandler::DEFAULT_COLUMNS.each do |col|
      assert_match /#{col}/, content
    end
  end

  should 'include field names in the generated CSV' do
    f1 = CustomFormsPlugin::TextField.create!(form: @form, name: 'Priority')
    f2 = CustomFormsPlugin::TextField.create!(form: @form, name: 'Description')
    content = @handler.generate_csv
    assert_match /#{f1.name}/, content
    assert_match /#{f2.name}/, content
  end

  should 'include default values in the generated CSV' do
    person = create_user('testuser', email: 'ze@mail.com').person
    submission = @form.submissions.create!(profile: person)
    content = @handler.generate_csv
    assert_match /#{person.name}/, content
    assert_match /#{person.email}/, content
    assert_match /#{submission.updated_at.strftime('%Y/%m/%d %T %Z')}/, content
  end

  should 'include all submissions in the generated CSV' do
    submission1 = @form.submissions.create!(profile: fast_create(Person))
    submission2 = @form.submissions.create!(profile: fast_create(Person))

    f1 = CustomFormsPlugin::TextField.create!(form: @form, name: 'Priority')
    answer1 = submission1.answers.create(field: f1, value: 'High')
    answer2 = submission2.answers.create(field: f1, value: 'Low')

    f2 = CustomFormsPlugin::SelectField.new(form: @form, name: 'OS')
    alt1 = f2.alternatives.new(label: 'Debian')
    alt2 = f2.alternatives.new(label: 'Ubuntu')
    f2.alternatives = [alt1, alt2]
    f2.save!
    submission1.answers.create(field: f2, value: alt2.id)
    submission2.answers.create(field: f2, value: alt1.id)

    content = @handler.generate_csv
    assert_match /#{answer1.value}/, content
    assert_match /#{answer2.value}/, content
    assert_match /#{alt1.label}/, content
    assert_match /#{alt2.label}/, content
  end

  should 'include city if it field is enabled' do
    person = fast_create(Person)
    person.city = 'Valhalla'

    Environment.any_instance.stubs(:active_person_fields).returns(['location'])
    @form.submissions.create!(profile: person)

    content = @handler.generate_csv
    assert_match /#{person.city}/, content
  end

  should 'not include city if field is disabled' do
    person = fast_create(Person)
    person.city = 'Valhalla'

    Environment.any_instance.stubs(:active_person_fields).returns([])
    @form.submissions.create!(profile: person)

    content = @handler.generate_csv
    assert_no_match /#{person.city}/, content
  end

  should 'import submissions from CSV' do
    CustomFormsPlugin::TextField.create!(form: @form, name: 'Question 1')
    CustomFormsPlugin::TextField.create!(form: @form, name: 'Question 2')

    csv_content = "Name,Email,Question 1,Question 2\n"
    csv_content += "rosa,rosa@mail.com,answer 1,answer 2\n"
    csv_content += "maria,maria@mail.com,answer 3,answer 4"

    assert_difference "@form.submissions.count", 2 do
      @handler.import_csv(csv_content)
    end

    answers = @form.submissions.map{ |s| s.answers.map{ |a| a.value } }
    answers = answers.flatten
    ["answer 1", "answer 2", "answer 3", "answer 4"].each do |answer|
      assert_includes answers, answer
    end
  end

  should 'flag imported submissions from CSV' do
    CustomFormsPlugin::TextField.create!(form: @form, name: 'Question 1')
    CustomFormsPlugin::TextField.create!(form: @form, name: 'Question 2')

    csv_content = "Name,Email,Question 1,Question 2\n"
    csv_content += "rosa,rosa@mail.com,answer 1,answer 2\n"
    csv_content += "maria,maria@mail.com,answer 3,answer 4"

    @handler.import_csv(csv_content)
    answers = @form.submissions.map(&:answers).flatten
    assert answers.all?(&:imported)
  end

  should 'accept multiple alternatives for select fields during import' do
    field = CustomFormsPlugin::SelectField.new(form: @form, name: 'OS', show_as: 'check_box')
    alt1 = field.alternatives.new(label: 'Debian')
    alt2 = field.alternatives.new(label: 'Ubuntu')
    field.alternatives = [alt1, alt2]
    field.save!

    csv_content = "Name,Email,OS\n"
    csv_content += "rosa,rosa@mail.com,Debian;Ubuntu"
    assert_difference "@form.submissions.count", 1 do
      @handler.import_csv(csv_content)
    end

    answer = @form.submissions.last.answer_for(field)
    answers = answer.value.split(',')
                    .map{ |id| CustomFormsPlugin::Alternative.find(id) }
    assert_equivalent [alt1, alt2], answers
  end

  should 'ignore errors and generate report' do
    CustomFormsPlugin::TextField.create!(form: @form, name: 'Question 1')
    field = CustomFormsPlugin::SelectField.new(form: @form, name: 'OS')
    alt1 = field.alternatives.new(label: 'Debian')
    alt2 = field.alternatives.new(label: 'Ubuntu')
    field.alternatives = [alt1, alt2]
    field.save!

    csv_content = "Name,Email,Question 1,OS\n"
    csv_content += "rosa,rosa@mail.com,a value,Debian\n"
    csv_content += "maria,maria@mail.com,other value,invalid\n"
    csv_content += "rosa,rosa@mail.com,a value,Ubuntu\n"
    report = @handler.import_csv(csv_content)

    assert_equal 1, report[:success_count]
    assert_equal 2, report[:errors].size
  end

  should 'save row number and content of errored lines' do
    CustomFormsPlugin::TextField.create!(form: @form, name: 'Question 1')
    CustomFormsPlugin::TextField.create!(form: @form, name: 'Question 2')

    row = "rosa,rosa@mail.com,Foo,Bar"
    csv_content = "Name,Email,Question 1,OS\n"
    csv_content += "rosa,rosa@mail.com,Foo,Bar\n"
    csv_content += "maria,maria@mail.com,Fuzz,Buzz\n"
    csv_content += row

    report = @handler.import_csv(csv_content)
    error = report[:errors].first
    assert_equal 4, error[:row_number]
    assert_equal row.split(','), error[:row]
  end

  should 'save row column number of errored lines' do
    CustomFormsPlugin::TextField.create!(form: @form, name: 'Question 1')
    CustomFormsPlugin::TextField.create!(form: @form, name: 'Question 2',
                                         mandatory: true)

    csv_content = "Name,Email,Question 1,Question 2\n"
    csv_content += "rosa,rosa@mail.com,Foo,Bar\n"
    csv_content += "maria,maria@mail.com,Fuzz,Buzz\n"
    csv_content += "rosa,rosa@mail.com,Foo,Bar\n"
    csv_content += "jose,jose@mail.com,Foo,"

    report = @handler.import_csv(csv_content)
    error = report[:errors].first
    assert_includes error[:errors].keys, 1
    error = report[:errors].last
    assert_includes error[:errors].keys, 3
  end
end
