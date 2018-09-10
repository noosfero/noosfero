Feature: Create tinyMCE article
  As an ordinary user
  I want to create an tinymce

  Background:
    Given the following users
      | login | name |
      | joaosilva | joao silva |
    Given I am logged in as "joaosilva"

  @selenium
  Scenario: mce complete  mode should show on message creation
    Given I am on /myprofile/joaosilva/cms/new?type=TextArticle
    Then The tinymce "toolbar" with index "0" should be "fullscreen | insertfile undo redo | copy paste | bold italic underline strikethrough removeformat backcolor | styleselect fontselect fontsizeselect | forecolor backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image | hilitecolor"
    And The tinymce "toolbar" with index "1" should be "print preview code media | table | macros"
    And The tinymce "menubar" should contain "edit insert view tools"
