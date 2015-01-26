Feature: Gravatar Support
  Unauthenticated users may comment content and are displayed with Gravatar
  pictures. The commenter with registered Gravatar image will have a link to
  his/her Gravatar profile, others will have a link to the Gravatar homepage.

  Background:
    Given the following users
      | login     | name       |
      | manuel | Manuel Silva |
    And the following articles
      | owner  | name       |
      | manuel | My Article |
    And the following comments
      | article    | author | name   | email                  | title | body   |
      | My Article | manuel |        |                        | 1 | Hi!    |
      | My Article |        | Aurium | aurium@gmail.com       | 2 | Hello! |
      | My Article |        | NoOne  | nobody@colivre.coop.br | 3 | Bye!   |

  @selenium
  Scenario: The Aurium's gravatar picture must link to his gravatar profile
    # because Aurium has his picture registered at garvatar.com.
    When I go to article "My Article"
    Then I should see "Aurium" linking to "//www.gravatar.com/24a625896a07aa37fdb2352e302e96de"

  @selenium
  Scenario: The NoOne's gravatar picture must link to Gravatar homepage
    # because NoOne <nobody@colivre.coop.br> has no picture registered.
    When I go to article "My Article"
    Then I should see "NoOne" linking to "//www.gravatar.com"

