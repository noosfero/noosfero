require 'test_helper'

class CustomFormsPlugin::SurveyBlockProfileTest < ActionDispatch::IntegrationTest

  def setup
    Environment.default.enable_plugin(CustomFormsPlugin)
    @user = create_user('jose').person
    @user.user.activate

    @my_block = CustomFormsPlugin::SurveyBlock.new
    @my_block.metadata['limit'] = 3

    @profile = fast_create(Community)
    @profile.create_default_set_of_boxes
    @profile.boxes.first.blocks << @my_block

    @form1 = create_survey('Form 1')
    @form2 = create_survey('Form 2', access: AccessLevels.levels[:users])
    @form3 = create_survey('Form 3', access: AccessLevels.levels[:related])
  end

  should 'only display surveys of the current profile' do
    another_profile = fast_create(Community)
    survey = create_survey('Should not', profile: another_profile)

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: @form1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: survey.name,
                  ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'list surveys accessible to visitors' do
    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: @form1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: @form2.name,
                  ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: @form3.name,
                  ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'list surveys accessible to logged users' do
    login('jose', 'jose')
    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: @form1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: @form2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: @form3.name,
                  ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'list surveys accessible to member users' do
    login('jose', 'jose')
    @profile.add_member(@user)

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: @form1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: @form2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: @form3.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'return open forms in survey list' do

    open_survey_1 =  create_survey('Open Survey 1', begining: DateTime.now - 1.day,
                                ending: DateTime.now + 2.days)
    open_survey_2 =  create_survey('Open Survey 2', ending: DateTime.now + 3.days)

    closed_survey =  create_survey('Closed Survey 1', ending: DateTime.now - 1.days)
    not_open_yet_survey =  create_survey('Not open yet Survey 1',
                                        begining: DateTime.now + 2.days)
    @my_block.metadata['status'] = 'not_closed'
    @my_block.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: open_survey_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: open_survey_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: closed_survey.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: not_open_yet_survey.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'return closed forms in survey list' do

    closed_survey_1 =  create_survey('Closed Survey 1', ending: DateTime.now - 1.days)
    closed_survey_2 =  create_survey('Closed Survey 2', ending: DateTime.now - 2.days)

    open_survey =  create_survey('Open Survey', ending: DateTime.now + 3.days)
    not_open_yet_survey =  create_survey('Not open yet Survey',
                                      begining: DateTime.now + 2.days)

    @my_block.metadata['status'] = 'closed'
    @my_block.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: closed_survey_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: closed_survey_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: open_survey.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: not_open_yet_survey.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'return not open yet forms in survey list' do

    not_open_yet_survey_1 =  create_survey('Not open yet Survey 1',
                                        begining: DateTime.now + 2.days)
    not_open_yet_survey_2 =  create_survey('Not open yet Survey 2',
                                        begining: DateTime.now + 1.days)

    closed_survey =  create_survey('Closed Survey', ending: DateTime.now - 1.days)
    open_survey =  create_survey('Open Survey', begining: DateTime.now,
                              ending: DateTime.now + 2.days)

    @my_block.metadata['status'] = 'not_open_yet'
    @my_block.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: not_open_yet_survey_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: not_open_yet_survey_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: open_survey.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: closed_survey.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'return all forms in survey list' do

    open_survey_1 =  create_survey('Open Survey 1', begining: DateTime.now,
                                ending: DateTime.now + 2.days)
    open_survey_2 =  create_survey('Open Survey 2', ending: DateTime.now + 3.days)

    closed_survey_1 =  create_survey('Closed Survey 1', ending: DateTime.now - 1.days)
    closed_survey_2 =  create_survey('Closed Survey 2', ending: DateTime.now - 2.days)

    not_open_yet_survey_1 =  create_survey('Not open yet Survey 1',
                                        begining: DateTime.now + 2.days)
    not_open_yet_survey_2 =  create_survey('Not open yet Survey 2',
                                        begining: DateTime.now + 1.days)

    @my_block.metadata['limit'] = 9
    @my_block.metadata['status'] = 'all'
    @my_block.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: open_survey_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: open_survey_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: closed_survey_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: closed_survey_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: not_open_yet_survey_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: not_open_yet_survey_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  private

  def create_survey(name, opts={})
    attrs = { name: name, kind: 'survey', profile: @profile }
    survey = CustomFormsPlugin::Form.new(attrs.merge(opts))
    field = CustomFormsPlugin::TextField.new(name: 'Question', form: survey)
    survey.fields << field
    survey.save!
    survey
  end

end
