require 'test_helper'

class CustomFormsPlugin::PollsBlockProfileTest < ActionDispatch::IntegrationTest

  def setup
    Environment.default.enable_plugin(CustomFormsPlugin)
    @user = create_user('jose').person
    @user.user.activate

    @my_block = CustomFormsPlugin::PollsBlock.new
    @my_block.metadata['limit'] = 3

    @profile = fast_create(Community)
    @profile.create_default_set_of_boxes
    @profile.boxes.first.blocks << @my_block

    @form1 = create_poll('Form 1')
    @form2 = create_poll('Form 2', access: AccessLevels.levels[:users])
    @form3 = create_poll('Form 3', access: AccessLevels.levels[:related])
  end

  should 'only list polls of the current profile' do
    another_profile = fast_create(Community)
    another_poll = create_poll('Should not', profile: another_profile)

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: @form1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: another_poll.name,
                  ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'list forms accessible to visitors' do
    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: @form1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: @form2.name,
                  ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: @form3.name,
                  ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'list forms accessible to logged users' do
    login('jose', 'jose')
    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: @form1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: @form2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: @form3.name,
                  ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'list forms accessible to member users' do
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

  should 'render submission in block and main content with different names' do
    login('jose', 'jose')
    submission = CustomFormsPlugin::Submission.new(form: @form1, profile: @user)
    submission.build_answers('0' => '0')
    submission.save!

    get "/profile/#{@profile.identifier}/query/#{@form1.identifier}"
    assert_tag tag: 'input', attributes: { name: /submission\[/ },
               ancestor: { tag: 'div', attributes: { class: /main-content/ } }
    assert_tag tag: 'input', attributes: { name: /block_submission\[/ },
               ancestor: { tag: 'div', attributes: { class: /block/ } }
  end

  should 'display submission form if poll is open and user did not answer it' do
    login('jose', 'jose')
    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'form',
               ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'display submission in the block if the user answered the poll' do
    login('jose', 'jose')
    submission = CustomFormsPlugin::Submission.new(form: @form1, profile: @user)
    submission.build_answers('0' => '0')
    submission.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'input', attributes: { name: /block_submission\[/ },
               ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
    assert_no_tag tag: 'input', attributes: { type: "submit" },
                  ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'display chart with results if poll is closed and has submissions' do
    @form1.update_attributes(ending: 1.day.ago)
    submission = CustomFormsPlugin::Submission.new(form: @form1, profile: @user)
    submission.build_answers('0' => '0')
    submission.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'div', attributes: { class: 'chart-wrapper' },
               ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'not display chart with results if poll is closed and has no submissions' do
    @form1.update_attributes(ending: 1.day.ago)

    get "/profile/#{@profile.identifier}"
    assert_no_tag tag: 'div', attributes: { class: 'chart-wrapper' },
                  ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'display partial results link if results are public' do
    @form1.update_attributes(access_result_options: 'public')
    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'a', attributes: { class: 'partial-results-link' },
               ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'not display partial results link if there are no results' do
    @form1.update_attributes(access_result_options: 'public',
                             ending: 1.day.ago)
    get "/profile/#{@profile.identifier}"
    assert_no_tag tag: 'a', attributes: { class: 'partial-results-link' },
                  ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'not display partial results link if poll is open and results are only public after it is closed' do
    @form1.update_attributes(access_result_options: 'public_after_ends')
    submission = CustomFormsPlugin::Submission.new(form: @form1, profile: @user)
    submission.build_answers('0' => '0')
    submission.save!

    get "/profile/#{@profile.identifier}"
    assert_no_tag tag: 'a', attributes: { class: 'partial-results-link' },
                  ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'display partial results link if poll is closed and results are only public after it is closed' do
    @form1.update_attributes(access_result_options: 'public_after_ends',
                             ending: 1.day.ago)
    submission = CustomFormsPlugin::Submission.new(form: @form1, profile: @user)
    submission.build_answers('0' => '0')
    submission.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'a', attributes: { class: 'partial-results-link' },
               ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'not display partial results link if poll results are private' do
    login('jose', 'jose')
    @form1.update_attributes(access_result_options: 'private')
    assert_no_tag tag: 'a', attributes: { class: 'partial-results-link' },
                   ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'display partial results link if poll results are private but user is a profile admin' do
    login('jose', 'jose')
    @form1.update_attributes(access_result_options: 'private')
    @profile.add_admin(@user)

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'a', attributes: { class: 'partial-results-link' },
               ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'display partial results link if poll results are private but user is an env admin' do
    login('jose', 'jose')
    @form1.update_attributes(access_result_options: 'private')
    Environment.default.add_admin(@user)

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'a', attributes: { class: 'partial-results-link' },
               ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'not display result chart or results link if the results are not avaiable' do
    login('jose', 'jose')
    @form1.update_attributes(access_result_options: 'private',
                             ending: 1.day.ago)
    submission = CustomFormsPlugin::Submission.new(form: @form1, profile: @user)
    submission.build_answers('0' => '0')
    submission.save!

    get "/profile/#{@profile.identifier}"
    assert_no_tag tag: 'div', attributes: { class: 'chart-wrapper' },
                  ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
    assert_no_tag tag: 'a', attributes: { class: 'partial-results-link' },
                  ancestor: { tag: 'div', attributes: { id: /#{@form1.identifier}/ } }
  end

  should 'return open forms in poll list' do

    open_poll_1 =  create_poll('Open Poll 1', begining: DateTime.now - 1.day,
                                ending: DateTime.now + 2.days)
    open_poll_2 =  create_poll('Open Poll 2', ending: DateTime.now + 3.days)

    closed_poll =  create_poll('Closed Poll 1', ending: DateTime.now - 1.days)
    not_open_yet_poll =  create_poll('Not open yet Poll 1',
                                        begining: DateTime.now + 2.days)
    @my_block.metadata['status'] = 'not_closed'
    @my_block.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: open_poll_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: open_poll_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: closed_poll.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: not_open_yet_poll.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'return closed forms in poll list' do

    closed_poll_1 =  create_poll('Closed Poll 1', ending: DateTime.now - 1.days)
    closed_poll_2 =  create_poll('Closed Poll 2', ending: DateTime.now - 2.days)

    open_poll =  create_poll('Open Poll', ending: DateTime.now + 3.days)
    not_open_yet_poll =  create_poll('Not open yet Poll',
                                      begining: DateTime.now + 2.days)

    @my_block.metadata['status'] = 'closed'
    @my_block.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: closed_poll_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: closed_poll_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: open_poll.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: not_open_yet_poll.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'return not open yet forms in poll list' do

    not_open_yet_poll_1 =  create_poll('Not open yet Poll 1',
                                        begining: DateTime.now + 2.days)
    not_open_yet_poll_2 =  create_poll('Not open yet Poll 2',
                                        begining: DateTime.now + 1.days)

    closed_poll =  create_poll('Closed Poll', ending: DateTime.now - 1.days)
    open_poll =  create_poll('Open Poll', begining: DateTime.now,
                              ending: DateTime.now + 2.days)

    @my_block.metadata['status'] = 'not_open_yet'
    @my_block.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: not_open_yet_poll_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: not_open_yet_poll_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: open_poll.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_no_tag tag: 'span', content: closed_poll.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  should 'return all forms in poll list' do

    open_poll_1 =  create_poll('Open Poll 1', begining: DateTime.now,
                                ending: DateTime.now + 2.days)
    open_poll_2 =  create_poll('Open Poll 2', ending: DateTime.now + 3.days)

    closed_poll_1 =  create_poll('Closed Poll 1', ending: DateTime.now - 1.days)
    closed_poll_2 =  create_poll('Closed Poll 2', ending: DateTime.now - 2.days)

    not_open_yet_poll_1 =  create_poll('Not open yet Poll 1',
                                        begining: DateTime.now + 2.days)
    not_open_yet_poll_2 =  create_poll('Not open yet Poll 2',
                                        begining: DateTime.now + 1.days)

    @my_block.metadata['limit'] = 9
    @my_block.metadata['status'] = 'all'
    @my_block.save!

    get "/profile/#{@profile.identifier}"
    assert_tag tag: 'span', content: open_poll_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: open_poll_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: closed_poll_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: closed_poll_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: not_open_yet_poll_1.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
    assert_tag tag: 'span', content: not_open_yet_poll_2.name,
               ancestor: { tag: 'div', attributes: { class: /form-item/ } }
  end

  private

  def create_poll(name, opts={})
    attrs = { name: name, kind: 'poll', profile: @profile }
    poll = CustomFormsPlugin::Form.new(attrs.merge(opts))
    field = CustomFormsPlugin::SelectField.new(name: 'Question', form: poll)

    field.alternatives << CustomFormsPlugin::Alternative.new(label: 'A1')
    field.alternatives << CustomFormsPlugin::Alternative.new(label: 'B1')
    poll.fields << field
    poll.save!
    poll
  end

end
