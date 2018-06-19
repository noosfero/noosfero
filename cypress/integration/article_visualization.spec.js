describe(" As a user \
  I want to change view modes \
  In order to see articles in fullscreen or not in fullscreen", function () {

    before(function() {
      cy.fixture('user').then((user) => {
        cy.login(user);
      });
    })

    it("viewing the article in fullscreen by default", function () {
      cy.fixture('user').then((user) => {
        cy.visit(`/${user["login"]}/blog/sample-article?fullscreen=1`)
          .then(() => {
            cy.get("#article-options-dropdown").contains("Exit full screen");
          });
      });
    })

    it("viewing the article not in fullscreen by default", function () {
      cy.fixture('user').then((user) => {
        cy.visit(`${user["login"]}/blog/sample-article`)
          .then(() => {
            cy.get("#article-options-dropdown").contains("Full screen");
          });
      });
    })

    it("changing the view mode from not in fullscreen to fullscreen", function () {
      cy.fixture('user').then((user) => {
        cy.visit(`/${user["login"]}/blog/sample-article`)
          .then(() => {
            cy.get("#article-options").click().then(() => {
              cy.contains("Full screen").click();
            });
            cy.get("#article-options").click().then(() => {
              cy.contains("Exit full screen");
            });
          });
      });
    })
  })
