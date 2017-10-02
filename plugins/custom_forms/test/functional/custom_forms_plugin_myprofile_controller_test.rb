require 'test_helper'
require_relative '../../controllers/custom_forms_plugin_myprofile_controller'

class CustomFormsPluginMyprofileControllerTest < ActionController::TestCase
  def setup
    @controller = CustomFormsPluginMyprofileController.new

    @profile = create_user('ze').person
    login_as(@profile.identifier)
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
  end

  attr_reader :profile

  should 'list forms associated with profile' do
    another_profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:profile => profile,
                                         :name => 'Free Software',
                                         :kind => 'survey',
                                         :identifier => 'free')
    f2 = CustomFormsPlugin::Form.create!(:profile => profile,
                                         :kind => 'survey',
                                         :name => 'Open Source',
                                         :identifier => 'open')
    f3 = CustomFormsPlugin::Form.create!(:profile => another_profile,
                                         :name => 'Open Source',
                                         :kind => 'survey',
                                         :identifier => 'open')
    p1 = CustomFormsPlugin::Form.create!(:profile => profile,
                                         :name => 'Copyleft',
                                         :kind => 'poll',
                                         :identifier => 'copy')
    p2 = CustomFormsPlugin::Form.create!(:profile => another_profile,
                                         :name => 'Copyleft',
                                         :kind => 'poll',
                                         :identifier => 'copy')

    get :index, :profile => profile.identifier

    assert_includes assigns(:forms)[:survey], f1
    assert_includes assigns(:forms)[:survey], f2
    assert_not_includes assigns(:forms)[:survey], f3
    assert_includes assigns(:forms)[:poll], p1
    assert_not_includes assigns(:forms)[:poll], p2
  end

  should 'destroy form' do
    form = CustomFormsPlugin::Form.create!(:profile => profile,
                                           :name => 'Free Software',
                                           :identifier => 'free')

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
          :identifier => 'my_form',
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

    form = CustomFormsPlugin::Form.find_by(name: 'My Form')
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
        :fields_attributes => fields,
        :identifier => 'my_form'
      }
    end
    form = CustomFormsPlugin::Form.find_by(name: 'My Form')
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
        :fields_attributes => fields,
        :identifier => 'cool_form'
      }
    end
    form = CustomFormsPlugin::Form.find_by(name: 'My Form')
    assert_equal 2, form.fields.count
    assert form.fields.first.name == "1"
    assert form.fields.last.name == "0"
  end

  should 'remove empty alternatives' do
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
          :identifier => 'cool-form',
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
                3 => {:label => ''}
              }
            }
          }
        }
    end

    form = CustomFormsPlugin::Form.find_by(name: 'My Form')
    field = form.fields[1]

    assert_equal 'Color', field.name
    assert_equal field.alternatives.map(&:label).sort, ['Red', 'Blue'].sort
    assert_equal field.show_as, 'radio'
    assert field.kind_of?(CustomFormsPlugin::SelectField)
  end

  should 'edit a form' do
    form = CustomFormsPlugin::Form.create!(:profile => profile,
                                           :name => 'Free Software',
                                           :identifier => 'free')
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
    form = CustomFormsPlugin::Form.create!(:profile => profile,
                                           :name => 'Free Software',
                                           :identifier => 'free')

    get :edit, :profile => profile.identifier, :id => form.id
    expects(:current_editor).returns(Article::Editor::TINY_MCE)

    assert_tag :tag => 'textarea',
      :attributes => { :id => 'form_description',
                       :class => /#{current_editor}/ }
  end

  should 'export submissions as csv' do
    form = CustomFormsPlugin::Form.create!(:profile => profile,
                                           :name => 'Free Software',
                                           :identifier => 'free')
    field = CustomFormsPlugin::TextField.create!(:name => "Title")
    form.fields << field

    answer = CustomFormsPlugin::Answer.create!(:value => 'example',
                                               :field => field)

    sub1 = create(CustomFormsPlugin::Submission, :author_name => "john",
                  :author_email => 'john@example.com', :form => form)
    sub1.answers << answer

    bob = create_user('bob').person
    sub2 = CustomFormsPlugin::Submission.create!(:profile => bob, :form => form)

    get :submissions, :profile => profile.identifier,
      :id => form.id, :format => 'csv'
    assert_equal 'text/csv', @response.content_type
    assert_equal 'Timestamp,Name,Email,Title', @response.body.split("\n")[0]
    assert_equal "#{sub1.updated_at.strftime('%Y/%m/%d %T %Z')},john,john@example.com,example", @response.body.split("\n")[1]
    assert_equal "#{sub2.updated_at.strftime('%Y/%m/%d %T %Z')},bob,#{bob.email},\"\"", @response.body.split("\n")[2]
  end

  should 'order submissions by name or time' do
    form = CustomFormsPlugin::Form.create!(:profile => profile,
                                           :name => 'Free Software',
                                           :identifier => 'free')
    field = CustomFormsPlugin::TextField.create!(:name => "Title")
    form.fields << field
    create(CustomFormsPlugin::Submission, :author_name => "john",
           :author_email => 'john@example.com', :form => form)
    bob = create_user('bob').person
    create(CustomFormsPlugin::Submission,
           :profile => bob, :form => form)

    get :submissions, :profile => profile.identifier,
      :id => form.id, :sort_by => 'time'
    assert_not_nil assigns(:sort_by)
    assert_select 'table.action-table', /Author\W*Time\W*john[\W\dh]*bob[\W\dh]*/

    get :submissions, :profile => profile.identifier,
      :id => form.id, :sort_by => 'author_name'
    assert_not_nil assigns(:sort_by)
    assert_select 'table.action-table', /Author\W*Time\W*bob[\W\dh]*john[\W\dh]*/
  end

  should 'list pending submissions for a form' do
    person = create_user('john').person
    form = CustomFormsPlugin::Form.create!(:profile => profile,
                                           :name => 'Free Software',
                                           :identifier => 'free')
    CustomFormsPlugin::AdmissionSurvey.create!(:form_id => form.id,
                                               :target => person,
                                               :requestor => profile)

    get :pending, :profile => profile.identifier, :id => form.id

    assert_tag :td, :content => person.name
  end

  should 'create a form with a uploaded image' do

    post :create, :profile => profile.identifier,
      :form => {
        :name => 'Form with image',
        :access => 'logged',
        :description => 'Cool form',
        :identifier => "form",
        :image => fixture_file_upload('/files/rails.png', 'image/png')
      }

    form = CustomFormsPlugin::Form.find_by(name: 'Form with image')
    assert_not_nil form.image
  end

  should 'update a form with an uploaded image' do

    post :create, :profile => profile.identifier,
      :form => {
        :name => 'Form with image',
        :access => 'logged',
        :description => 'Cool form',
        :identifier => "form",
        :image => fixture_file_upload('/files/rails.png', 'image/png')
      }

    form = CustomFormsPlugin::Form.last
    assert Gallery.last.images.find(form.image.id)

    post :update, :profile => profile.identifier,
      :form => {
        :name => 'Form with image',
        :access => 'logged',
        :description => 'Cool form',
        :identifier => "form",
        :image => fixture_file_upload('/files/fruits.png', 'image/png')
      },
      :id =>  form.id

    assert_raise ActiveRecord::RecordNotFound do
      Gallery.last.images.find(form.image.id)
    end
    form.reload

    assert Gallery.last.images.find(form.image.id)
  end

  should 'create a galery to store form images' do

    post :create, :profile => profile.identifier,
      :form => {
        :name => 'Form with image',
        :access => 'logged',
        :description => 'Cool form',
        :identifier => "form",
        :image => fixture_file_upload('/files/rails.png', 'image/png')
      }

    gallery = Gallery.find_by(:profile => profile, :name => "Query Gallery")
    assert_not_nil gallery
  end

  should 'add uploaded file inside query gallery' do

    post :create, :profile => profile.identifier,
      :form => {
        :name => 'Form with image',
        :access => 'logged',
        :description => 'Cool form',
        :identifier => "form",
        :image => fixture_file_upload('/files/rails.png', 'image/png')
      }

    gallery = Gallery.find_by(:profile => profile, :name => "Query Gallery")
    assert_equal gallery.images.first.name, "rails.png"
  end

  should 'remove upload form image from form and gallery on update' do

    post :create, :profile => profile.identifier,
      :form => {
        :name => 'Form with image',
        :access => 'logged',
        :description => 'Cool form',
        :identifier => "form",
        :image => fixture_file_upload('/files/rails.png', 'image/png')
      }

    form = CustomFormsPlugin::Form.last
    assert_not_nil form.image
    gallery_images = Gallery.last.images.count

    post :update, :profile => profile.identifier,
      :form => {
        :name => 'Form with image',
        :access => 'logged',
        :description => 'Cool form',
        :identifier => "form",
        :image => fixture_file_upload('/files/rails.png', 'image/png'),
        :remove_image => "1"
      },
      :id => form.id

    form.reload
    assert_equal Gallery.last.images.count, (gallery_images - 1)
    assert_nil form.image
  end
end
