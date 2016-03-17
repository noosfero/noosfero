require 'test_helper'
require_relative '../../controllers/custom_forms_plugin_myprofile_controller'

class CustomFormsPluginMyprofileControllerTest < ActionController::TestCase
  def setup
    @controller = CustomFormsPluginMyprofileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = create_user('profile').person
    login_as(@profile.identifier)
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
  end

  attr_reader :profile

  should 'list forms associated with profile' do
    another_profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    f2 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Open Source')
    f3 = CustomFormsPlugin::Form.create!(:profile => another_profile, :name => 'Open Source')

    get :index, :profile => profile.identifier

    assert_includes assigns(:forms), f1
    assert_includes assigns(:forms), f2
    assert_not_includes assigns(:forms), f3
  end

  should 'destroy form' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    assert CustomFormsPlugin::Form.exists?(form.id)
    post :remove, :profile => profile.identifier, :id => form.id
    refute CustomFormsPlugin::Form.exists?(form.id)
  end

  should 'create a form' do
    format = '%Y-%m-%d %H:%M'
    begining = Time.now.strftime(format)
    ending = (Time.now + 1.day).strftime(format)
    assert_difference 'CustomFormsPlugin::Form.count', 1 do
      post :create, :profile => profile.identifier,
        :form => {
          :name => 'My Form',
          :access => 'logged',
          :begining => begining,
          :ending => ending,
          :description => 'Cool form',
          :fields_attributes => {
            1 => {
              :name => 'Name',
              :default_value => 'Jack',
              :type => 'CustomFormsPlugin::TextField'
            },
            2 => {
              :name => 'Color',
              :show_as => 'radio',
              :type => 'CustomFormsPlugin::SelectField',
              :alternatives_attributes => {
                1 => {:label => 'Red'},
                2 => {:label => 'Blue'},
                3 => {:label => 'Black'}
              }
            }
          }
        }
    end

    form = CustomFormsPlugin::Form.find_by_name('My Form')
    assert_equal 'logged', form.access
    assert_equal begining, form.begining.strftime(format)
    assert_equal ending, form.ending.strftime(format)
    assert_equal 'Cool form', form.description
    assert_equal 2, form.fields.count

    f1 = form.fields[0]
    f2 = form.fields[1]

    assert_equal 'Name', f1.name
    assert_equal 'Jack', f1.default_value
    assert f1.kind_of?(CustomFormsPlugin::TextField)

    assert_equal 'Color', f2.name
    assert_equal f2.alternatives.map(&:label).sort, ['Red', 'Blue', 'Black'].sort
    assert_equal f2.show_as, 'radio'
    assert f2.kind_of?(CustomFormsPlugin::SelectField)
  end

  should 'create fields in the order they are sent when no position defined' do
    format = '%Y-%m-%d %H:%M'
    num_fields = 10
    begining = Time.now.strftime(format)
    ending = (Time.now + 1.day).strftime(format)
    fields = {}
    num_fields.times do |i|
      fields[i] = {
        :name => (10-i).to_s,
        :default_value => '',
        :type => 'CustomFormsPlugin::TextField'
      }
    end
    assert_difference 'CustomFormsPlugin::Form.count', 1 do
      post :create, :profile => profile.identifier,
        :form => {
        :name => 'My Form',
        :access => 'logged',
        :begining => begining,
        :ending => ending,
        :description => 'Cool form',
        :fields_attributes => fields
      }
    end
    form = CustomFormsPlugin::Form.find_by_name('My Form')
    assert_equal num_fields, form.fields.count
    lst = 10
    form.fields.each do |f|
      assert f.name.to_i == lst
      lst = lst - 1
    end
  end

  should 'create fields in any position size' do
    format = '%Y-%m-%d %H:%M'
    begining = Time.now.strftime(format)
    ending = (Time.now + 1.day).strftime(format)
    fields = {}
    fields['0'] = {
      :name => '0',
      :default_value => '',
      :type => 'CustomFormsPlugin::TextField',
      :position => '999999999999'
    }
    fields['1'] = {
      :name => '1',
      :default_value => '',
      :type => 'CustomFormsPlugin::TextField',
      :position => '1'
    }
    assert_difference 'CustomFormsPlugin::Form.count', 1 do
      post :create, :profile => profile.identifier,
        :form => {
        :name => 'My Form',
        :access => 'logged',
        :begining => begining,
        :ending => ending,
        :description => 'Cool form',
        :fields_attributes => fields
      }
    end
    form = CustomFormsPlugin::Form.find_by_name('My Form')
    assert_equal 2, form.fields.count
    assert form.fields.first.name == "1"
    assert form.fields.last.name == "0"
  end

  should 'edit a form' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    format = '%Y-%m-%d %H:%M'
    begining = Time.now.strftime(format)
    ending = (Time.now + 1.day).strftime(format)

    assert_equal form.fields.length, 0

    post :update, :profile => profile.identifier, :id => form.id,
      :form => {:name => 'My Form', :access => 'logged', :begining => begining, :ending => ending, :description => 'Cool form',
        :fields_attributes => {1 => {:name => 'Source'}}}

    form.reload
    assert_equal form.fields.length, 1

    field = form.fields.last

    assert_equal 'logged', form.access
    assert_equal begining, form.begining.strftime(format)
    assert_equal ending, form.ending.strftime(format)
    assert_equal 'Cool form', form.description
    assert_equal 'Source', field.name
  end

  should 'render TinyMce Editor for description' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')

    get :edit, :profile => profile.identifier, :id => form.id

    assert_tag :tag => 'textarea', :attributes => { :id => 'form_description', :class => 'mceEditor' }
  end

  should 'export submissions as csv' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    field = CustomFormsPlugin::TextField.create!(:name => "Title")
    form.fields << field

    answer = CustomFormsPlugin::Answer.create!(:value => 'example', :field => field)

    sub1 = create(CustomFormsPlugin::Submission, :author_name => "john", :author_email => 'john@example.com', :form => form)
    sub1.answers << answer

    bob = create_user('bob').person
    sub2 = CustomFormsPlugin::Submission.create!(:profile => bob, :form => form)

    get :submissions, :profile => profile.identifier, :id => form.id, :format => 'csv'
    assert_equal 'text/csv', @response.content_type
    assert_equal 'Timestamp,Name,Email,Title', @response.body.split("\n")[0]
    assert_equal "#{sub1.updated_at.strftime('%Y/%m/%d %T %Z')},john,john@example.com,example", @response.body.split("\n")[1]
    assert_equal "#{sub2.updated_at.strftime('%Y/%m/%d %T %Z')},bob,#{bob.email},\"\"", @response.body.split("\n")[2]
  end

  should 'order submissions by name or time' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    field = CustomFormsPlugin::TextField.create!(:name => "Title")
    form.fields << field
    sub1 = create(CustomFormsPlugin::Submission, :author_name => "john", :author_email => 'john@example.com', :form => form)
    bob = create_user('bob').person
    sub2 = create(CustomFormsPlugin::Submission, :profile => bob, :form => form)

    get :submissions, :profile => profile.identifier, :id => form.id, :sort_by => 'time'
    assert_not_nil assigns(:sort_by)
    assert_select 'table.action-table', /Author\W*Time\W*john[\W\dh]*bob[\W\dh]*/

    get :submissions, :profile => profile.identifier, :id => form.id, :sort_by => 'author_name'
    assert_not_nil assigns(:sort_by)
    assert_select 'table.action-table', /Author\W*Time\W*bob[\W\dh]*john[\W\dh]*/
  end

  should 'list pending submissions for a form' do
    person = create_user('john').person
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software', :for_admission => true)
    task = CustomFormsPlugin::AdmissionSurvey.create!(:form_id => form.id, :target => person, :requestor => profile)

    get :pending, :profile => profile.identifier, :id => form.id

    assert_tag :td, :content => person.name
  end
end
