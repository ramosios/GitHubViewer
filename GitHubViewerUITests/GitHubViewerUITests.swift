//
//  GitHubViewerUITests.swift
//  GitHubViewerUITests
//
//  Created by Jorge Ramos on 24/06/25.
//
//  UI tests validating user list loading, navigation, and search functionality.
//

import XCTest

final class GitHubViewerUITests: XCTestCase {

    private var app: XCUIApplication!

    /// Sets up the app environment before each test.
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
        app.launch()
    }

    /// Tests that the user list loads, allows tapping on a user, and navigates to the detail view.
    func testUserListLoadsAndNavigatesToDetail() throws {
        let firstLogin = app.staticTexts.matching(identifierPrefix: "UserLogin_").firstMatch

        XCTAssertTrue(firstLogin.waitForExistence(timeout: 5), "UserLogin label not found")

        // Ensures the element is interactable before tapping.
        let tapExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "hittable == true"),
            object: firstLogin
        )
        XCTAssertEqual(XCTWaiter().wait(for: [tapExpectation], timeout: 5), .completed, "UserLogin label is not hittable")

        firstLogin.tap()

        // Verifies that the detail view is shown by checking the navigation bar title.
        let detailNavBar = app.navigationBars["User Detail"]
        XCTAssertTrue(detailNavBar.waitForExistence(timeout: 10), "Navigation bar with title 'User Detail' not found")
    }

    /// Tests that the search bar filters users correctly by GitHub login name.
    func testSearchUserFlow() throws {
        XCTContext.runActivity(named: "Search for a username") { _ in
            let searchField = app.searchFields.firstMatch
            XCTAssertTrue(searchField.waitForExistence(timeout: 10), "Search field not found")
            searchField.tap()
            searchField.typeText("octocat")
        }

        XCTContext.runActivity(named: "Verify search result appears") { _ in
            let userResult = app.staticTexts.matching(identifierPrefix: "UserLogin_").firstMatch
            XCTAssertTrue(userResult.waitForExistence(timeout: 15), "Search result did not appear")
        }
    }
}

// MARK: - Helpers

/// Adds convenience filtering for UI tests based on identifier prefix.
extension XCUIElementQuery {
    func matching(identifierPrefix prefix: String) -> XCUIElementQuery {
        self.matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
    }
}
