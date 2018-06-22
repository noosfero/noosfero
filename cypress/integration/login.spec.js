describe("Test the login page", function () {
  it("check if username and password appears", function () {
    var url = "/account/login";
    cy.visit(url);
    cy.get("input[type=text]#main_user_login");
    cy.get("#content input#user_password");
  })
})
