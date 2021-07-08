describe('Gitlab Login', () => {
  it('Check admin is able to login', () => {
    // test login
    cy.visit('/users/sign_in')
    cy.get('input[id="user_login"]').type('root')
    cy.get('input[id="user_password"]').type(Cypress.env('adminpassword'))
    cy.get('input[type="submit"]').click()

    cy.visit('/admin')
    cy.get('a[title="Admin Overview"]').should('be.visible')

    // approve new user
    // KC v14 changed something that broke the CI helm tests. Error says user already exists.
    // the test user is not actually created in the previous test
    // cy.visit('/admin/users')
    // cy.get('a[href="/admin/application_settings/general#js-signup-settings"]').click()
    // cy.get('li.home a[href="/admin"]').first().click()
    // cy.get('a[title="Users"]').click()
    // cy.get('a[data-qa-selector="pending_approval_tab"]').click()
    // cy.get('div[id="__BVID__30"]').click()
    // cy.get('a[href="/admin/users/randouser/approve"]').click()
    
  })
})
