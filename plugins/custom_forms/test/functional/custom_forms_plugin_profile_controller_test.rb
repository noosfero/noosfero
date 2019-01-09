require 'test_helper'

class CustomFormsPluginProfileControllerTest < ActionController::TestCase
  def setup
    @profile = create_user('profile').person
    login_as(@profile.identifier)
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
  end

  attr_reader :profile

  should 'save submission if fields are ok' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software', :identifier => 'free-software')
    field1 = CustomFormsPlugin::TextField.create(:name => 'Name', :form => form, :mandatory => true)
    field2 = CustomFormsPlugin::TextField.create(:name => 'License', :form => form)

    assert_difference 'CustomFormsPlugin::Submission.count', 1 do
      post :show, :profile => profile.identifier, :id => form.identifier, :submission => {field1.id.to_s => 'Noosfero', field2.id.to_s => 'GPL'}
    end
    assert_redirected_to :action => 'confirmation',
                         :submission_id => assigns(:submission).id
  end

  should 'save submission if fields are ok and user is not logged in' do
    logout
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software', :identifier => 'free-software')
    field = CustomFormsPlugin::TextField.create(:name => 'Name', :form => form)

    assert_difference 'CustomFormsPlugin::Submission.count', 1 do
      post :show, :profile => profile.identifier, :id => form.identifier, :author_name => "john", :author_email => 'john@example.com', :submission => {field.id.to_s => 'Noosfero'}
    end
    assert_redirected_to :action => 'confirmation',
                         :submission_id => assigns(:submission).id
  end

  should 'not save empty submission' do
    form = CustomFormsPlugin::Form.create!(profile: profile, name: 'Free Software', identifier: 'free-software', kind: 'survey')
    field1 = CustomFormsPlugin::TextField.create!(name: 'Name', form: form, mandatory: true)
    alternative_a = CustomFormsPlugin::Alternative.new(:label => 'A')
    alternative_b = CustomFormsPlugin::Alternative.new(:label => 'B')
    field2 = CustomFormsPlugin::SelectField.new(name: 'Select Field', form: form, mandatory: true)
    field2.alternatives << [alternative_a, alternative_b]
    field2.save!

    assert_no_difference 'CustomFormsPlugin::Submission.count' do
      post :show, :profile => profile.identifier, :id => form.identifier, :submission => {field1.id.to_s => '', field2.id.to_s => '0'}
    end

    assert_tag :tag => 'div', attributes: { class: 'errorExplanation', id: 'errorExplanation' }
    assert_tag :tag => 'li', content: "#{field1.name} is mandatory."
    assert_tag :tag => 'li', content: "#{field2.name} is mandatory."
  end

  should 'display errors if user is not logged in and author_name is not uniq' do
    logout
    form = CustomFormsPlugin::Form.create(:profile => profile, :name => 'Free Software', :identifier => 'free-software')
    field = CustomFormsPlugin::TextField.create(:name => 'Name', :form => form)
    submission = CustomFormsPlugin::Submission.create(:form => form, :author_name => "john", :author_email => 'john@example.com')

    assert_no_difference 'CustomFormsPlugin::Submission.count' do
      post :show, :profile => profile.identifier, :id => form.identifier, :author_name => "john", :author_email => 'john@example.com', :submission => {field.id.to_s => 'Noosfero'}
    end
    assert_equal "Submission could not be saved", session[:notice]
    assert_tag :tag => 'div', :attributes => { :class => 'errorExplanation', :id => 'errorExplanation' }
  end

  should 'disable fields if form expired' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software', :beginning => Time.now + 1.day, :identifier => 'free-software')
    form.fields << CustomFormsPlugin::TextField.create(:name => 'Field Name', :form => form, :default_value => "First Field")

    get :show, :profile => profile.identifier, :id => form.identifier

    assert_tag :tag => 'input', :attributes => {:disabled => 'disabled'}
  end

  should 'show expired message' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software', :beginning => Time.now + 1.day, :identifier => 'free-software')
    form.fields << CustomFormsPlugin::TextField.create(:name => 'Field Name', :form => form, :default_value => "First Field")

    get :show, :profile => profile.identifier, :id => form.identifier

    assert_tag :tag => 'h2', :content => 'Sorry, you can\'t fill this form yet'

    form.beginning = Time.now - 2.days
    form.ending = Time.now - 1.days
    form.save

    get :show, :profile => profile.identifier, :id => form.identifier

    assert_tag :tag => 'h2', :content => 'Sorry, you can\'t fill this form anymore'
  end

  should 'show submission confirmation with fields if user can access' do
    form = CustomFormsPlugin::Form.create(:profile => profile, :name => 'Free Software', identifier: 'free-software')
    form.fields << CustomFormsPlugin::TextField.create(name: 'Field Name', form: form, default_value: "First Field")
    submission = CustomFormsPlugin::Submission.create(form: form, author_name: "john", author_email: 'john@example.com')

    get :confirmation, profile: profile.identifier, submission_id: submission.id
    assert_match /Field Name/, response.body
  end

  should 'show submission confirmation without fields if is a visitor and results are private' do
    org = fast_create(Organization)
    form = CustomFormsPlugin::Form.create(profile: org, name: 'Free Software', identifier: 'free-software', access_result_options: 'private')
    form.fields << CustomFormsPlugin::TextField.create(name: 'Field Name', form: form, default_value: "First Field")
    submission = CustomFormsPlugin::Submission.create(form: form, author_name: "john", author_email: 'john@example.com')

    logout
    get :confirmation, profile: org.identifier, submission_id: submission.id
    assert_no_match /Field Name/, response.body
  end

  should 'show submission confirmation without fields if user cannout access' do
    org = fast_create(Organization)
    form = CustomFormsPlugin::Form.create(profile: org, name: 'Free Software', identifier: 'free-software', access_result_options: 'private')
    form.fields << CustomFormsPlugin::TextField.create(name: 'Field Name', form: form, default_value: "First Field")

    other_profile = fast_create(Person)
    submission = CustomFormsPlugin::Submission.create(form: form, profile: other_profile)

    get :confirmation, profile: org.identifier, submission_id: submission.id
    assert_no_match /Field Name/, response.body
  end

  should 'show submission confirmation without fields if the current user made the submission' do
    org = fast_create(Organization)
    form = CustomFormsPlugin::Form.create(profile: org, name: 'Free Software', identifier: 'free-software', access_result_options: 'private')
    form.fields << CustomFormsPlugin::TextField.create(name: 'Field Name', form: form, default_value: "First Field")
    submission = CustomFormsPlugin::Submission.create(form: form, profile: profile)

    get :confirmation, profile: org.identifier, submission_id: submission.id
    assert_match /Field Name/, response.body
  end

  should 'show submission confirmation with fields to visitors if it is public' do
    form = CustomFormsPlugin::Form.create(profile: profile, name: 'Free Software', identifier: 'free-software', access_result_options: 'public')
    form.fields << CustomFormsPlugin::TextField.create(name: 'Field Name', form: form, default_value: "First Field")
    submission = CustomFormsPlugin::Submission.create(form: form, author_name: "john", author_email: 'john@example.com')

    logout
    get :confirmation, profile: profile.identifier, submission_id: submission.id
    assert_match /Field Name/, response.body
  end

  should 'return 404 if submission does not exist' do
    get :confirmation, profile: profile.identifier, submission_id: 'nope'
    assert_response :not_found
  end

  should 'show query review page' do

    form = CustomFormsPlugin::Form.create!(:profile => profile,
                                            :name => 'Free Software',
                                            :identifier => 'free')
    submission = CustomFormsPlugin::Submission.create!(:form => form,
                                                       :profile => profile)
    radio_field = CustomFormsPlugin::Field.create!(
      :name => 'What is your favorite food?',
      :form => form,
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

    get :review, :profile => profile.identifier, :id => form.identifier

    assert_tag :tag => 'h4', :attributes => {:class => 'review_text_align'},
                             :content => /What is your favorite food?/
    assert_tag :tag => 'table', :attributes => { :class => 'results-table' },
               :descendant => { :tag => 'td', :content => /bread/ }
  end

  should 'define filters default values' do
    get :queries, :profile => profile.identifier
    assert_equal 'recent', assigns(:order)
    assert_equal 'all', assigns(:kind)
    assert_equal 'all', assigns(:status)
  end

  should 'order forms' do
    survey1 = CustomFormsPlugin::Form.new(:profile => profile, :name => 'Survey 1', :identifier => 'survey1')
    survey1.created_at = Time.now - 2.days
    survey1.save!
    survey2 = CustomFormsPlugin::Form.new(:profile => profile, :name => 'Survey 2', :identifier => 'survey2')
    survey2.created_at = Time.now - 1.day
    survey2.save!
    survey3 = CustomFormsPlugin::Form.new(:profile => profile, :name => 'Survey 3', :identifier => 'survey3')
    survey3.created_at = Time.now
    survey3.save!

    get :queries, :profile => profile.identifier, :order => 'older'

    assert_equivalent assigns(:forms), [survey3, survey2, survey1]
  end

  should 'filter forms by kind' do
    survey = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Survey', :identifier => 'survey', :kind => 'survey')
    poll1 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Poll 1', :identifier => 'poll1', :kind => 'poll')
    poll2 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Poll 2', :identifier => 'poll2', :kind => 'poll')

    get :queries, :profile => profile.identifier, :kind => 'poll'

    assert_includes assigns(:forms), poll1
    assert_includes assigns(:forms), poll2
    assert_not_includes assigns(:forms), survey
  end

  should 'filter forms by status' do
    opened_survey = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Opened Survey', :identifier => 'opened-survey', :beginning => Time.now - 1.day)
    closed_survey = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Closed Survey', :identifier => 'closed-survey', :ending => Time.now - 1.day)
    to_come_survey = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'To Come Survey', :identifier => 'to-come-survey', :beginning => Time.now + 1.day)

    get :queries, :profile => profile.identifier, :status => 'opened'

    assert_includes assigns(:forms), opened_survey
    assert_not_includes assigns(:forms), closed_survey
    assert_not_includes assigns(:forms), to_come_survey
  end

  should 'filter forms by query' do
    space_wars = CustomFormsPlugin::Form.create!(:profile => profile,
                                                 :name => 'Space Wars',
                                                 :identifier => 'space-wars')
    star_trek = CustomFormsPlugin::Form.create!(:profile => profile,
                                                :name => 'Star Trek',
                                                :identifier => 'star-trek')
    star_wars = CustomFormsPlugin::Form.create!(:profile => profile,
                                                :name => 'Star Wars',
                                                :identifier => 'star-wars')

    get :queries, :profile => profile.identifier, :q => 'star'

    assert_includes assigns(:forms), star_wars
    assert_includes assigns(:forms), star_trek
    assert_not_includes assigns(:forms), space_wars
  end

  should 'forbid access to form based on entitlement' do
    community = fast_create(Community)
    form = CustomFormsPlugin::Form.create!(:profile => community,
                                           :name => 'Free Software',
                                           :identifier => 'free-software',
                                           :access => Entitlement::Levels.levels[:related])

    get :show, :profile => community.identifier, :id => form.identifier
    assert_response :forbidden
    assert_template 'shared/access_denied'
  end

  should 'allow access to form based on entitlement' do
    community = fast_create(Community)
    form = CustomFormsPlugin::Form.create!(:profile => community,
                                           :name => 'Free Software',
                                           :identifier => 'free-software',
                                           :access => Entitlement::Levels.levels[:visitors])

    get :show, :profile => community.identifier, :id => form.identifier
    assert_response :success
    assert_template 'custom_forms_plugin_profile/show'
  end

  should 'filter forms for visitors' do
    logout
    community = fast_create(Community)
    f1 = CustomFormsPlugin::Form.create!(:name => 'For Visitors',
                                         :profile => community,
                                         :access => Entitlement::Levels.levels[:visitors])
    f2 = CustomFormsPlugin::Form.create!(:name => 'For Logged Users',
                                         :profile => community,
                                         :access => Entitlement::Levels.levels[:users])
    f3 = CustomFormsPlugin::Form.create!(:name => 'For Members',
                                         :profile => community,
                                         :access => Entitlement::Levels.levels[:related])

    get :queries, :profile => community.identifier

    assert_includes assigns(:forms), f1
    assert_not_includes assigns(:forms), f2
    assert_not_includes assigns(:forms), f3
  end

  should 'filter forms for logged users' do
    community = fast_create(Community)
    f1 = CustomFormsPlugin::Form.create!(:name => 'For Visitors', :profile => community, :access => Entitlement::Levels.levels[:visitors])
    f2 = CustomFormsPlugin::Form.create!(:name => 'For Logged Users', :profile => community, :access => Entitlement::Levels.levels[:users])
    f3 = CustomFormsPlugin::Form.create!(:name => 'For Members', :profile => community, :access => Entitlement::Levels.levels[:related])

    get :queries, :profile => community.identifier

    assert_includes assigns(:forms), f1
    assert_includes assigns(:forms), f2
    assert_not_includes assigns(:forms), f3
  end

  should 'filter forms for related users' do
    community = fast_create(Community)
    community.add_member(profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'For Visitors', :profile => community, :access => Entitlement::Levels.levels[:visitors])
    f2 = CustomFormsPlugin::Form.create!(:name => 'For Logged Users', :profile => community, :access => Entitlement::Levels.levels[:users])
    f3 = CustomFormsPlugin::Form.create!(:name => 'For Members', :profile => community, :access => Entitlement::Levels.levels[:related])

    get :queries, :profile => community.identifier

    assert_includes assigns(:forms), f1
    assert_includes assigns(:forms), f2
    assert_includes assigns(:forms), f3
  end

  should 'allow access to results' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software', :identifier => 'free-software', :access_result_options => 'private')
    get :review, :profile => profile.identifier, :id => form.identifier
    assert_response :success
    assert_template 'custom_forms_plugin_profile/review'
  end

  should 'forbid access to results' do
    logout
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software', :identifier => 'free-software', :access_result_options => 'private')
    get :review, :profile => profile.identifier, :id => form.identifier
    assert_response :forbidden
    assert_template 'shared/access_denied'
  end
 
  should 'download csv with all submissions' do
   form = CustomFormsPlugin::Form.create!(
     :profile => profile,
      :name => 'Free Software',
      :identifier => 'free',
      :kind => 'survey'
    )
    alternative_a = CustomFormsPlugin::Alternative.new(:label => 'A')
    alternative_b = CustomFormsPlugin::Alternative.new(:label => 'B')
    field = CustomFormsPlugin::SelectField.new(:name => 'Select Field', :form => form)
    field.alternatives << [alternative_a, alternative_b]
    field.save!
    another_field = CustomFormsPlugin::TextField.create!(:name => 'Text Field',
                                                          :form => form)
    submission = CustomFormsPlugin::Submission.create!(:form => form,
                                                       :profile => profile)
    another_submission = CustomFormsPlugin::Submission.create!(:form => form,
                                                        :profile => profile)
    answer = CustomFormsPlugin::Answer.create!(:field => field,
                                               :value => nil,
                                               :submission => submission)
    form_answer = CustomFormsPlugin::FormAnswer.create!(answer_id: answer.id,
                                                        alternative_id: field.alternatives[0].id)
    answer.form_answers << form_answer
    answer.save!
    another_answer = CustomFormsPlugin::Answer.create!(:field => another_field,
                                                       :value => "my-another-answer",
                                                       :submission => another_submission)

    get :review, :profile => profile.identifier, :id => form.identifier, :format => 'csv'

    assert_response :success
    assert_equal 'text/csv', @response.content_type
    assert_match profile.name, @response.body
    assert_match field.alternatives[0].label, @response.body
    assert_match another_answer.value, @response.body
  end

  should 'download csv of a single field answers' do
    form = CustomFormsPlugin::Form.create!(:profile => profile,
                                           :name => 'Free Software',
                                           :identifier => 'free')

    field = CustomFormsPlugin::TextField.create!(:name => 'Field-1',
                                            :form => form)

    submission = CustomFormsPlugin::Submission.create!(:form => form,
                                              :profile => profile)

    another_profile = create_user('another-profile').person
    another_submission = CustomFormsPlugin::Submission.create!(:form => form,
                                                :profile => another_profile)

    answer = CustomFormsPlugin::Answer.create!(:field => field,
                                               :value => "my-answer",
                                               :submission => submission)

    empty_answer = CustomFormsPlugin::Answer.create!(:field => field,
                                                :value => "",
                                                :submission => another_submission)

    get :download_field_answers, :profile => profile.identifier, :id => form.identifier,
                                 :field_name => field.name, :format => 'csv'

    assert_response :success
    assert_equal 'text/csv', @response.content_type
    assert_match profile.name, @response.body
    assert_match answer.value, @response.body
    assert_match another_profile.name, @response.body
  end

  should 'display form options to profile admin' do
    community = fast_create(Community)
    community.add_admin(profile)
    form = community.forms.create!(name: 'Free Software')

    get :show, :profile => community.identifier, :id => form.identifier
    assert_tag tag: 'div', attributes: { class: 'custom-form-options' }
  end

  should 'display form options to environment admin' do
    community = fast_create(Community)
    community.environment.add_admin(profile)
    form = community.forms.create!(name: 'Free Software')

    get :show, :profile => community.identifier, :id => form.identifier
    assert_tag tag: 'div', attributes: { class: 'custom-form-options' }
  end

  should 'not display form options to visitors' do
    community = fast_create(Community)
    form = community.forms.create!(name: 'Free Software')

    get :show, :profile => community.identifier, :id => form.identifier
    !assert_tag tag: 'div', attributes: { class: 'custom-form-options' }
  end
end
