const url = "http://0.0.0.0:4000";
const user = {"login": "johndoe", "name": "John Doe", "password": "test"};


function startServer() {
    cy.exec(`docker exec 37156b151e04 cat /tmp/noosfero.pid | xargs kill -9`, {failOnNonZeroExit: false});
    cy.exec(`docker exec 37156b151e04 rails s -b 0.0.0.0 -d -e test -P /tmp/noosfero.pid`, {failOnNonZeroExit: false});
}

function fillDB() {
    cy.exec(`docker exec 37156b151e04 rake db:test:prepare`);
    cy.exec(`docker exec 37156b151e04 rake db:fixtures:load RAILS_ENV=test`);
}

describe(" As a user \
  I want to change view modes \
  In order to see articles in fullscreen or not in fullscreen", function () {

  before(function() {
    fillDB();
    startServer();
    cy.login(url, user);
  })

  it("viewing the article in fullscreen by default", function () {
    cy.visit(`${noosfero}/johndoe/blog/sample-article?fullscreen=1`)
      .then(() => {
        cy.get("#article-options-dropdown").contains("Exit full screen");
      });
  })

  it("viewing the article not in fullscreen by default", function () {
    cy.visit(`${noosfero}/johndoe/blog/sample-article`)
      .then(() => {
        cy.get("#article-options-dropdown").contains("Full screen");
      });
  })

  it("changing the view mode from not in fullscreen to fullscreen", function () {
    cy.visit(`${noosfero}/johndoe/blog/sample-article`)
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
