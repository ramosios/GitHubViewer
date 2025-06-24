//
//  GitHubViewerUITests.swift
//  GitHubViewerUITests
//
//  Created by Jorge Ramos on 24/06/25.
//

import XCTest

final class GitHubViewerUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
        app.launch()
    }

    func testUserListLoadsAndNavigatesToDetail() throws {
        let firstLogin = app.staticTexts.matching(identifierPrefix: "UserLogin_").firstMatch

        XCTAssertTrue(firstLogin.waitForExistence(timeout: 5), "UserLogin label not found")

        let tapExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "hittable == true"),
            object: firstLogin
        )
        XCTAssertEqual(XCTWaiter().wait(for: [tapExpectation], timeout: 5), .completed, "UserLogin label is not hittable")

        firstLogin.tap()

        let detailNavBar = app.navigationBars["User Detail"]
        XCTAssertTrue(detailNavBar.waitForExistence(timeout: 10), "Navigation bar with title 'User Detail' not found")
    }


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
extension XCUIElementQuery {
    func matching(identifierPrefix prefix: String) -> XCUIElementQuery {
        self.matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
    }
}
