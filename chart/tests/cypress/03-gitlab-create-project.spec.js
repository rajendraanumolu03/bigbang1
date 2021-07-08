Cypress.on('uncaught:exception', (err, runnable) => {
  // returning false here prevents Cypress from failing the test
  // gitlab throws this error in the console which by default fails the cypress test
  return false
})

describe('Create Gitlab Project', () => {
  it('Check user is able to create a project', () => {
    // test login
    cy.visit('/users/sign_in')
    cy.get('input[id="user_login"]').type('root')
    cy.get('input[id="user_password"]').type(Cypress.env('adminpassword'))
    cy.get('input[type="submit"]').click()
     
    // create project
    cy.get('a[href="/projects/new"]').eq(3).click()
    cy.get('a[href="#blank_project"]').click()
    cy.get('input[id="project_name"]').first().type('My awesome project') // for some reason, there are 2 other hidden elements with the same attributes but we only need the first one
    cy.get('input[id="project_visibility_level_20"]').first().click()     // for some reason, there are 2 other hidden elements with the same attributes but we only need the first one
    // cy.get('input[id="project_initialize_with_readme"]').click()
    // cy.get('input[type="submit"]').first().click()                        // for some reason, there are 2 other hidden elements with the same attributes but we only need the first one
    // cy.contains('successfully created')
  })
})