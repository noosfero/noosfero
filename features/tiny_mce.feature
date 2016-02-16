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
    Given I am on /myprofile/joaosilva/cms/new?type=TinyMceArticle
    Then The tinymce "toolbar1" should be "fullscreen | insertfile undo redo | copy paste | bold italic underline | styleselect fontsizeselect | forecolor backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image"
    And The tinymce "menubar" should be "edit insert view tools"
    And The tinymce "toolbar2" should contain "print preview code media | table"
