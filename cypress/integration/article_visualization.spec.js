const url = "http://0.0.0.0:4000";
const user = {"login": "johndoe", "name": "John Doe", "password": "test"};

describe(" As a user \
  I want to change view modes \
  In order to see articles in fullscreen or not in fullscreen", function () {

  before(function() {
    cy.exec(`docker exec 028de0397262 rake cypress:server:prepareDB`)
    cy.exec(`docker exec 028de0397262 rake cypress:server:start`);
    cy.login(url, user);
  })

  it("viewing the article in fullscreen by default", function () {
    cy.visit(`${url}/johndoe/blog/sample-article?fullscreen=1`)
      .then(() => {
        cy.get("#article-options-dropdown").contains("Exit full screen");
      });
  })

  it("viewing the article not in fullscreen by default", function () {
    cy.visit(`${url}/johndoe/blog/sample-article`)
      .then(() => {
        cy.get("#article-options-dropdown").contains("Full screen");
      });
  })

  it("changing the view mode from not in fullscreen to fullscreen", function () {
    cy.visit(`${url}/johndoe/blog/sample-article`)
      .then(() => {
        cy.get("#article-options").click().then(() => {
          cy.contains("Full screen").click();
        });
        cy.get("#article-options").click().then(() => {
          cy.contains("Exit full screen");
        });
      });
  })
})
