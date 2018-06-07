const noosfero = "http://localhost:4000";

describe("Test the login page", function () {
  it("check if username and password appears", function () {
    cy.visit(noosfero);
    cy.get("#user_login");
    cy.get("#user_password");
  })
})
